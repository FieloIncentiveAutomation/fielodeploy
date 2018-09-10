package com.fielo.deploy.controller;

import javax.servlet.http.HttpSession;

import org.json.simple.JSONObject;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequestMapping("/packageselector")
public class PackageSelector {
	
	@RequestMapping(method = RequestMethod.GET, value="/config")
	public String getConfigurations(@RequestParam final String licence, @RequestParam final String cip, 
			@RequestParam final String invoicing, @RequestParam final String training, @RequestParam final String registration, 
			@RequestParam final String salesforceLeads, @RequestParam final String salesforceOpportunities, 
			@RequestParam final String salesforceOrders, @RequestParam final String grs
			) throws Exception {
		
		//Get all configurations
		JSONObject objConfig = new JSONObject();

		objConfig.put("licence", checkField(licence));
		objConfig.put("cip", checkField(cip));
		objConfig.put("invoicing", checkField(invoicing));
		objConfig.put("training", checkField(training));
		objConfig.put("registration", checkField(registration));
		objConfig.put("salesforceLeads", checkField(salesforceLeads));
		objConfig.put("salesforceOpportunities", checkField(salesforceOpportunities));
		objConfig.put("salesforceOrders", checkField(salesforceOrders));	
		objConfig.put("grs", checkField(grs));

		// Send to Function X the configurations
		return "teste pegou no java:" + licence;		
		
	}
	
	//  Function that checks if the field exists 
	public String checkField(String fieldConfig) {
		if (fieldConfig == null) {
			return "";
		}
		return fieldConfig;
	}	
	
}
