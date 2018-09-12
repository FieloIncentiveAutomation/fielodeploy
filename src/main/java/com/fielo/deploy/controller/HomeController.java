package com.fielo.deploy.controller;

import static org.eclipse.egit.github.core.client.IGitHubConstants.SEGMENT_REPOS;

import java.net.URL;
import java.net.URLDecoder;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.InputStreamReader;
import java.io.StringWriter;
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
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
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
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.Element;


import com.fielo.deploy.utils.GithubUtil;
import com.force.sdk.connector.ForceServiceConnector;
import com.force.sdk.oauth.context.ForceSecurityContextHolder;
import com.force.sdk.oauth.exception.ForceOAuthSessionExpirationException;
import com.google.gson.Gson;
import com.sforce.rest.QueryResult;
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
import com.sforce.soap.partner.Connector;
import com.sforce.soap.partner.DescribeGlobalResult;
import com.sforce.soap.partner.DescribeGlobalSObjectResult;
import com.sforce.soap.partner.PartnerConnection;
import com.sforce.ws.ConnectionException;
import com.sforce.ws.ConnectorConfig;
import com.sforce.ws.bind.TypeMapper;
import com.sforce.ws.parser.XmlOutputStream;

@Controller
@RequestMapping("/home")
public class HomeController {
	
	@Autowired
    ServletContext context;
	
	HttpServletRequest servletRequest;
	ForceServiceConnector forceConnector;
	
		
	@RequestMapping(method = RequestMethod.GET, value="")
	public String confirm(HttpSession session, Map<String, Object> map) throws Exception {
		
		String reposList = "";
		File file = new File(context.getRealPath("/") + "Fielo-ProgramTypes.txt");
		if(!file.exists() || ((System.currentTimeMillis() - file.lastModified())/3600000) > 0){
			//llamo github
			reposList = new ObjectMapper().writeValueAsString(GithubUtil.getJsonFromGithub("Fielo-ProgramTypes"));
			
			if(!file.exists()){
				//creo arquivo
				file.createNewFile();
			}
			
			FileWriter fileWriter = new FileWriter(file, false);
            fileWriter.write(reposList);
            fileWriter.close();   
		}else{
			//get arquivo
			JSONParser parser = new JSONParser();
			try{
				reposList = parser.parse(new FileReader(file.getAbsolutePath())).toString().replace("\\","");
			}catch(java.io.FileNotFoundException e){
				System.out.println(e.getMessage());
			}
		}
		
		System.out.println(reposList);
		
		map.put("items", reposList);
		
		return "home";
	}
	
	
	
	@ResponseBody
	@RequestMapping(method = { RequestMethod.POST }, value="/checkcommunity")
	public String checkCommunity(HttpServletRequest request, HttpSession session, Map<String, Object> map) throws Exception
	{

		String flag = "true";
		
		
		ConnectorConfig config = new ConnectorConfig();
		
		//config.setUsername(USERNAME);
	    //config.setPassword(PASSWORD);
	
		
		try
		{
			//connection = Connector.newConnection();
			ForceServiceConnector connector = new ForceServiceConnector(ForceServiceConnector.getThreadLocalConnectorConfig());
			PartnerConnection connection = connector.getConnection();
			String query = "SELECT Id From Network";
			com.sforce.soap.partner.QueryResult result = connection.query(query);
			if(result.getSize()>0)
			{
				flag = "true";
			}			
		}
		catch(Exception ex)
		{
			System.out.println("Exception in main : " + ex);
		}

		 return flag;
	}
	
	@ResponseBody
	@RequestMapping(method = { RequestMethod.POST }, value="/checkversionplt")
	public String checkVersionPLT(HttpServletRequest request, HttpSession session, Map<String, Object> map) throws Exception
	{

		String flag = "false";
		ConnectorConfig config = new ConnectorConfig();
		
		//config.setUsername(USERNAME);
	    //config.setPassword(PASSWORD);
		ForceServiceConnector connector = new ForceServiceConnector(ForceServiceConnector.getThreadLocalConnectorConfig());
		PartnerConnection connection = connector.getConnection();

		try
		{
			//connection = Connector.newConnection();
		
			String query = "SELECT NamespacePrefix, MajorVersion, MinorVersion  FROM Publisher WHERE NamespacePrefix = 'FieloPLT'";
			com.sforce.soap.partner.QueryResult result = connection.query(query);
			if(result.getSize()>0)
			{
				System.out.println(result.getRecords());
				flag = "true";
			}			
		}
		catch(Exception ex)
		{
			System.out.println("Exception in main : " + ex);
		}
	

		 return flag;
	}
	
}
