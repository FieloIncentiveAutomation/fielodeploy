package com.fielo.deploy.utils;

import java.util.ArrayList;
import java.util.List;

import org.codehaus.jackson.map.ObjectMapper;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestTemplate;

//import com.fielo.deploy.controller.ProgramSelectController.RepoWrapper;

public class GithubUtil {
	
	public static ArrayList<RepoWrapper> getJsonFromGithub(String owner){
		RestTemplate restTemplate = new RestTemplate();
		ResponseEntity<ArrayList<RepoWrapper>> repoResponse =
		        restTemplate.exchange("https://api.github.com/users/" + owner + "/repos",
		                    HttpMethod.GET, null, new ParameterizedTypeReference<ArrayList<RepoWrapper>>() {});
		
		ArrayList<RepoWrapper> items = repoResponse.getBody();
		
		return items;
	}
	
	public class RepoWrapper{
		public String name;
		public String full_name;
	}
	
}
