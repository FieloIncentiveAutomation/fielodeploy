package com.fielo.deploy.controller;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.util.Map;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.codehaus.jackson.map.ObjectMapper;
import org.json.simple.parser.JSONParser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.fielo.deploy.utils.GithubUtil;
import com.force.sdk.connector.ForceServiceConnector;
import com.force.sdk.oauth.context.ForceSecurityContextHolder;
import com.force.sdk.oauth.context.SecurityContext;



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
	public String checkCommunity(HttpServletRequest request, HttpSession session) throws Exception
	{

		String flag = "false";
		
		 return flag;
	}

}
