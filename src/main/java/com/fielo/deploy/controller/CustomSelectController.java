package com.fielo.deploy.controller;

import static org.eclipse.egit.github.core.client.IGitHubConstants.SEGMENT_REPOS;

import java.net.URL;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.InputStreamReader;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;

import javax.xml.namespace.QName;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.net.ssl.HttpsURLConnection;

import org.codehaus.jackson.annotate.JsonIgnore;
import org.codehaus.jackson.map.ObjectMapper;
import org.eclipse.egit.github.core.IRepositoryIdProvider;
import org.eclipse.egit.github.core.RepositoryContents;
import org.eclipse.egit.github.core.RepositoryId;
import org.eclipse.egit.github.core.client.RequestException;
import org.eclipse.egit.github.core.client.GitHubClient;
import org.eclipse.egit.github.core.client.GitHubRequest;
import org.eclipse.egit.github.core.client.GitHubResponse;
import org.eclipse.egit.github.core.service.ContentsService;
import org.eclipse.egit.github.core.service.RepositoryService;
import org.json.simple.parser.JSONParser;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;

import com.force.sdk.connector.ForceServiceConnector;
import com.force.sdk.oauth.exception.ForceOAuthSessionExpirationException;
import com.sforce.soap.metadata.AsyncResult;
import com.sforce.soap.metadata.CodeCoverageWarning;
import com.sforce.soap.metadata.DeployMessage;
import com.sforce.soap.metadata.DeployOptions;
import com.sforce.soap.metadata.DeployResult;
import com.sforce.soap.metadata.DescribeMetadataObject;
import com.sforce.soap.metadata.DescribeMetadataResult;
import com.sforce.soap.metadata.MetadataConnection;
import com.sforce.soap.metadata.Package;
import com.sforce.soap.metadata.PackageTypeMembers;
import com.sforce.soap.metadata.RunTestFailure;
import com.sforce.soap.metadata.RunTestsResult;
import com.sforce.ws.bind.TypeMapper;
import com.sforce.ws.parser.XmlOutputStream;

import com.fielo.deploy.utils.GithubUtil;

@Controller
@RequestMapping("/customselect")
public class CustomSelectController {
	
	@RequestMapping(method = RequestMethod.GET, value="")
	public String confirm(HttpSession session, Map<String, Object> map) throws Exception {
		
		ArrayList<String> owners = new ArrayList<String>();
		owners.add("Fielo-Apps");
		owners.add("Fielo-Plugins");
		owners.add("Fielo-Connectors");
		owners.add("Fielo-Themes");
		
		map.put("reposList", new ObjectMapper().writeValueAsString(owners));
		
		Map<String, ArrayList<GithubUtil.RepoWrapper>> reposMap = new HashMap<String, ArrayList<GithubUtil.RepoWrapper>>();
		for(String owner : owners){
			//String reposList = "";
			ArrayList<GithubUtil.RepoWrapper> items = new ArrayList<GithubUtil.RepoWrapper>();
			
			File file = new File("/Users/Lenovo/fieloRepos/fielodeploy/src/main/webapp/" + owner + ".txt");
			if(!file.exists() || ((System.currentTimeMillis() - file.lastModified())/3600000) > 0){
				//llamo github
				items = GithubUtil.getJsonFromGithub(owner);
				
				if(!file.exists()){
					//creo arquivo
					file.createNewFile();
				}
				
				FileWriter fileWriter = new FileWriter(file, false);
	            fileWriter.write(new ObjectMapper().writeValueAsString(items));
	            fileWriter.close();   
			}else{
				//get arquivo
				JSONParser parser = new JSONParser();
				try{
					items = (ArrayList<GithubUtil.RepoWrapper>)parser.parse(new FileReader(file.getAbsolutePath()));
				}catch(java.io.FileNotFoundException e){
					System.out.println(e.getMessage());
				}
			}
			
			//System.out.println(reposList);
			
			reposMap.put(owner, items);
			
			
			
			/*RestTemplate restTemplate = new RestTemplate();
			ResponseEntity<List<RepoWrapper>> repoResponse =
			        restTemplate.exchange("https://api.github.com/users/"+ org + "/repos",
			                    HttpMethod.GET, null, new ParameterizedTypeReference<List<RepoWrapper>>() {});
			
			List<RepoWrapper> items = repoResponse.getBody();
			reposMap.put(org, items);*/
			
			
			
		}
		
		System.out.println(reposMap);
		
		map.put("reposMap", new ObjectMapper().writeValueAsString(reposMap));
		
		return "customselect";
	}
	
}