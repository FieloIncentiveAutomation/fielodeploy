package com.fielo.deploy.utils;

import java.util.ArrayList;
import java.util.List;

import org.codehaus.jackson.map.ObjectMapper;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestTemplate;

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
	
	public static JSONObject getJsonFromGithub(String owner, String repo){
		JSONObject json = new JSONObject(); 
		try {
			json = (JSONObject) (new JSONParser()).parse("https://raw.githubusercontent.com/" + owner + "/" + repo + "/master/config.json");
		} catch (Exception e) {
			e.printStackTrace();
		}
		return json;
	}
	
	
	
	public class RepoWrapper{
		public String name;
		public String full_name;
	}
	
}
