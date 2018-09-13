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
		return handleDuplicates(getFullDeployList(selection));
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
		        JSONObject repoInfo = GithubUtil.getRepoInfo(getGitHubName(deployItem.get("name").toString()));
		        // If resource is a repository, separate owner and repository name
		        if (repoInfo.get("type").toString().equals("repository")) {
		     		String name = getGitHubName(deployItem.get("name").toString());
		    		int separator = name.indexOf('/');
		    		String repoName = name.substring(separator + 1);
		    		String repoOwner = name.substring(0, separator);   		
			        repoInfo.put("name", repoName);
			        repoInfo.put("repoOwner", repoOwner);		        	
		        }
		        JSONArray dependencies = GithubUtil.getDependencies(repoInfo);
		        repoInfo.remove("dependencies");
	    		deployList.add(repoInfo);     		
	    		JSONArray deepDependecies = getFullDeployList(dependencies);
	    		
	    		// Checks for circular dependencies - if an original source appears again in its inheritance tree
    	    	String repoFullName = getFullName(repoInfo);
	    		Iterator<?> dependenciesIterator = deepDependecies.iterator();
	    	    while (dependenciesIterator.hasNext()) {
	    	    	if (getFullName((JSONObject) dependenciesIterator.next()).equals(repoFullName)) {
	                    throw new IllegalArgumentException("Circular dependency found in: " + repoFullName);	    	    		
	    	    	}
	    	    }	    
	    		
		        deployList = concatenateStart(deployList, deepDependecies );
	    		break;
		    // If type of resource is package, just add it to the list
	    	case "package":
	    		//Change this static resource in new version
	    		if (deployItem.get("name").toString().equals("checkboxFieloPlataform")) {
	    			JSONObject packagePLT = new JSONObject(); 
	    			packagePLT.put("name", "FieloPLT");
	    			packagePLT.put("type", "package");
	    			packagePLT.put("version", "2.56.6");
	    			deployList.add(packagePLT);
	    		}
	    		else {
	    			deployList.add(deployItem);
	    		}
	    		break;
    		default:
                throw new IllegalArgumentException("Invalid source type: " + type);
	    	}
   	    }		
	    
    	return deployList;    
	}
    
	private static String getFullName(JSONObject deployItem) {
    	String name = deployItem.get("name").toString();
		return deployItem.get("type").toString().equals("repository") ? deployItem.get("repoOwner").toString() + "/" + name : name;
	}
	
	private static JSONArray handleDuplicates(JSONArray deployList) {  
		JSONArray result = new JSONArray();
		Iterator<?> iterator = deployList.iterator();
		Map<String, JSONObject> control = new HashMap<String, JSONObject>(); // Control map showing the unique items added to the list
	    while (iterator.hasNext()) {
	    	JSONObject deployItem = (JSONObject) iterator.next();
	    	String fullName = getFullName(deployItem);
	    	// If item is not repeated, it is added to the list
	    	if (!control.containsKey(fullName)) {
	    		control.put(fullName, deployItem);
	    		result.add(deployItem);
	    	} else {
	    		// If repeated item is a package, the newest version is used
	    		if (deployItem.get("type").toString().equals("package")) {
	    			String currentVersion = deployItem.get("version").toString();
	    			JSONObject controlDeployItem = control.get(fullName);
	    			// If version in the control map (and consequently in the result list) is smaller
	    			if (controlDeployItem.get("version").toString().compareTo(currentVersion) < 0) { 
	    				// Update the control map
	    				control.put(fullName, deployItem);
	    				// Update version in the result list
	    				for (int i = 0; i < result.size(); i++) {
	    				    JSONObject resultItem = (JSONObject) result.get(i);
	    				    if(resultItem.get("name").toString().equals(fullName)) {
	    				    	resultItem.put("version", currentVersion);
	    				    	break;
	    				    }
	    				}	    			
	    			}
	    		}
	    	}
	    }	    
		return result;
	}
	
	private static JSONObject getRepoInfo(String name) throws IOException, ParseException {
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
		public String description;
	}
	
	public static String getGitHubName(String name) {
		
		switch (name) {
		
		case "invoicing":
			name = "Fielo-Apps/fieloprp";
    		break;
		case "training":
			name = "Fielo-Apps/fieloelr";
    		break;
		case "CIP":
			name = "Fielo-ProgramTypes/CIP";
    		break;
		case "grs":
			name = "Fielo-Connectors/fielogrs";
    		break;
		case "sendgrid":
			name = "Fielo-Connectors/fieloplt-sendgrid";
    		break;
		} 
		return name;
	}
}
