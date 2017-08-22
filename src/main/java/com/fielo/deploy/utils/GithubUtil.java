package com.fielo.deploy.utils;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.URL;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestTemplate;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;


//import com.fielo.deploy.controller.ProgramSelectController.RepoWrapper;

public class GithubUtil {

	// Allocated via your GitHub Account Settings, set as environment vars, provides increased limits per hour for GitHub API calls
	public static String GITHUB_CLIENT_ID = "GITHUB_CLIENT_ID";
	public static String GITHUB_CLIENT_SECRET = "GITHUB_CLIENT_SECRET";
	public static String GITHUB_TOKEN = "ghtoken";

	public static ArrayList<RepoWrapper> getJsonFromGithub(String owner){
		RestTemplate restTemplate = new RestTemplate();
		ResponseEntity<ArrayList<RepoWrapper>> repoResponse =
				restTemplate.exchange("https://api.github.com/users/" + owner + "/repos?client_id=" + System.getenv(GITHUB_CLIENT_ID) + "&client_secret=" + System.getenv(GITHUB_CLIENT_SECRET),
						HttpMethod.GET, null, new ParameterizedTypeReference<ArrayList<RepoWrapper>>() {});

		ArrayList<RepoWrapper> items = repoResponse.getBody();

		return items;
	}
	
	public static JSONArray getDeployList(JSONArray selection) throws IOException, ParseException {
		return removeDuplicates(getFullDeployList(selection));
	}

	@SuppressWarnings("unchecked")
	private static JSONArray getFullDeployList(JSONArray selection) throws IOException, ParseException {
		JSONArray deployList = new JSONArray();
		
		Iterator<?> iterator = selection.iterator();
	    while (iterator.hasNext()) {
	    	JSONObject deployItem = (JSONObject) iterator.next();
	    	String type = deployItem.get("type").toString();    	
	    	switch (type) {
	    	// If type of resource is linkRepository, check the config.json in the URL
	    	case "linkRepository":
		        JSONObject repoInfo = GithubUtil.getRepoInfo(deployItem.get("name").toString());
		        // If resource is a repository, separate owner and repository name
		        if (repoInfo.get("type").toString().equals("repository")) {
		     		String name = deployItem.get("name").toString();
		    		int separator = name.indexOf('/');
		    		String repoName = name.substring(separator + 1);
		    		String repoOwner = name.substring(0, separator);   		
			        repoInfo.put("name", repoName);
			        repoInfo.put("repoOwner", repoOwner);		        	
		        }
		        JSONArray dependencies = GithubUtil.getDependencies(repoInfo);
		        repoInfo.remove("dependencies");
	    		deployList.add(repoInfo); 
		        deployList = concatenateStart(deployList, getFullDeployList(dependencies));
	    		break;
		    // If type of resource is package, just add it to the list
	    	case "package":
		        deployList.add(deployItem);
	    		break;
    		default:
                throw new IllegalArgumentException("Invalid source type: " + type);
	    	}
   	    }		
	    
    	return deployList;    
	}
    
	private static JSONArray removeDuplicates(JSONArray deployList) {  
		JSONArray result = new JSONArray();
		Iterator<?> iterator = deployList.iterator();
		Map<String, JSONObject> control = new HashMap<String, JSONObject>();
	    while (iterator.hasNext()) {
	    	JSONObject deployItem = (JSONObject) iterator.next();
	    	// TODO: Adjust this first, basic version: 
	    	// 	- Not considering version possible differences
	    	// 	- Not considering repo owners
	    	//	- Removing first occurrence of duplicates
	    	String name = deployItem.get("name").toString();
	    	String fullName = deployItem.get("type").toString().equals("repository") ? deployItem.get("repoOwner").toString() + "/" + name : name;
	    	if (!control.containsKey(fullName)) {
	    		control.put(fullName, deployItem);
	    		result.add(deployItem);
	    	}
	    }	    
		return result;
	}
	
	private static JSONObject getRepoInfo(String name) throws IOException, ParseException {
		// TODO: REMOVE IT AFTER ADJUSTING FILE NAME ON REPOSITORY!!!
		if (name.equals("Fielo-Plugins/fielocms-fieloplt")) {
			return readJsonFromUrl("https://raw.githubusercontent.com/" + name + "/master/config,json");
		}
		return readJsonFromUrl("https://raw.githubusercontent.com/" + name + "/master/config.json");
	}

	private static JSONObject readJsonFromUrl(String url) throws IOException, ParseException {
		InputStream is = new URL(url).openStream();
		try {
			BufferedReader rd = new BufferedReader(new InputStreamReader(is, Charset.forName("UTF-8")));
			String jsonText = readAll(rd);
			JSONObject json = (JSONObject) (new JSONParser()).parse(jsonText);
			return json;
		} finally {
			is.close();
		}
	}

	private static String readAll(Reader rd) throws IOException {
		StringBuilder sb = new StringBuilder();
		int cp;
		while ((cp = rd.read()) != -1) {
			sb.append((char) cp);
		}
		return sb.toString();
	}

	private static JSONArray getDependencies(JSONObject repoInfo) {

		if (repoInfo.keySet().contains("dependencies")) {
			return (JSONArray) repoInfo.get("dependencies");
		} else {
			return new JSONArray();
		}	
	}	
	
	private static JSONArray concatenateStart(JSONArray jsonArray1, JSONArray jsonArray2) {
		Iterator<?> iterator = jsonArray1.iterator();
	    while (iterator.hasNext()) {
	    	jsonArray2.add((JSONObject) iterator.next()); 	
	    }		
		return jsonArray2;
	}
	
	public class RepoWrapper{
		public String name;
		public String full_name;
	}
}
