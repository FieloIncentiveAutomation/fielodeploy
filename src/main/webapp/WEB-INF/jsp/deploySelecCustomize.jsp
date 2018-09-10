<!DOCTYPE html>
<html>
	<head>
	    <meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<meta name="description" content="Fielo Deploy">
		<meta name="author" content="Fielo">
		<title>Fielo Deploy Tool</title>
		<link rel="shortcut icon" href="static/img/favicon.ico" />

		<!-- Custom Styles -->
		<link rel="stylesheet" href="static/css/style.css"/>

		<!-- Lightning Package -->
		<link rel="stylesheet" type="text/css" href="static/salesforce/assets/styles/salesforce-lightning-design-system.css" />

		<!-- Bootstrap --> 
		<!-- Latest compiled and minified CSS -->
		<link rel="stylesheet" href="static/css/bootstrap.min.css">
		<!-- Optional theme -->
		<link rel="stylesheet" href="static/bootstrap-theme.min.css">

		<!-- Latest compiled and minified JavaScript -->
		<script type="text/javascript" src="static/js/jquery-latest.min.js" ></script>
		<script type="text/javascript" src="static/js/bootstrap.min.js"></script>
		<!-- Custom Scritps -->
		<script type="text/javascript" src="static/js/scripts.js"></script>
	</head>
	<body bgcolor="#ffffff">
		<div class="container">
			<p class="h1 header1-padding"> 
				<img src="static/salesforce/assets/icons/utility/settings.svg" alt="Fielo Plataform Logo" class="icon">
					Welcome to Fielo Custom Program Installation
			</p>
			<div class="row">
				<div class="col-md-12 col-sm-12 col-xs-12 form-group salesforce">
					<fieldset class="slds-form-element">
					  <label class="labeltext labelpadding">Licences</label><br>
					  <div class="slds-form-element__control">
					    <span class="slds-radio">
					      <input type="radio" id="customerCommunity" value="customerCommunity" name="licence" checked="checked" />
					      <label class="slds-radio__label radioInline" for="customerCommunity">
					        <span class="slds-radio_faux customfauxRadio"></span>
					        <span class="slds-form-element__label customLabel">Customer Community</span>
					      </label>
					    </span>
					    <span class="slds-radio">
					      <input type="radio" id="partnerCommunity" value="partnerCommunity" name="licence" />
					      <label class="slds-radio__label radioInline" for="partnerCommunity">
					        <span class="slds-radio_faux customfauxRadio"></span>
					        <span class="slds-form-element__label customLabel">Partner Community</span>
					      </label>
					    </span>
					  </div>
					</fieldset>
				</div>
			</div>
			<div class="row">
				<div class="col-md-12 col-sm-12 col-xs-12 form-group">
			    	<label class="labeltext labelpadding">Incentivize Behaviors</label><br>
			    	<div class="slds-form-element">
					  <div class="slds-form-element__control">
					    <span class="slds-checkbox">
					      <input type="checkbox" name="options" id="invoicing" value="invoicing" class="classDisable" />
					      <label class="slds-checkbox__label checkboxInline" for="invoicing">
					        <span class="slds-checkbox_faux customfaux"></span>
					        <span class="slds-form-element__label customLabel">Invoicing</span>
					      </label>
					    </span>
					  </div>
					</div>
					<div class="slds-form-element">
					  <div class="slds-form-element__control">
					    <span class="slds-checkbox">
					      <input type="checkbox" name="options" id="training" value="training" class="classDisable" />
					      <label class="slds-checkbox__label checkboxInline" for="training">
					        <span class="slds-checkbox_faux customfaux"></span>
					        <span class="slds-form-element__label customLabel">Training</span>
					      </label>
					    </span>
					  </div>
					</div>
					<div class="slds-form-element">
					  <div class="slds-form-element__control">
					    <span class="slds-checkbox">
					      <input type="checkbox" name="options" id="registration" value="registration" class="classDisable" />
					      <label class="slds-checkbox__label checkboxInline" for="registration">
					        <span class="slds-checkbox_faux customfaux"></span>
					        <span class="slds-form-element__label customLabel">Registration</span>
					      </label>
					    </span>
					  </div>
					</div>
					<div class="slds-form-element">
					  <div class="slds-form-element__control">
					    <span class="slds-checkbox salesforce">
					      <input type="checkbox" name="options" id="salesforceLeads" value="salesforceLeads" />
					      <label class="slds-checkbox__label checkboxInline" for="salesforceLeads">
					        <span class="slds-checkbox_faux customfaux"></span>
					        <span class="slds-form-element__label customLabel">Salesforce leads</span>
					      </label>
					    </span>
					  </div>
					</div>
					<div class="slds-form-element">
					  <div class="slds-form-element__control">
					    <span class="slds-checkbox salesforce">
					      <input type="checkbox" name="options" id="salesforceOpportunities" value="salesforceOpportunities" />
					      <label class="slds-checkbox__label checkboxInline" for="salesforceOpportunities">
					        <span class="slds-checkbox_faux customfaux"></span>
					        <span class="slds-form-element__label customLabel">Salesforce opportunities</span>
					      </label>
					    </span>
					  </div>
					</div>
					<div class="slds-form-element">
					  <div class="slds-form-element__control">
					    <span class="slds-checkbox salesforce">
					      <input type="checkbox" name="options" id="salesforceOrders" value="salesforceOrders" />
					      <label class="slds-checkbox__label checkboxInline" for="salesforceOrders">
					        <span class="slds-checkbox_faux customfaux"></span>
					        <span class="slds-form-element__label customLabel">Salesforce orders</span>
					      </label>
					    </span>
					  </div>
					</div>
				</div>
			</div>
			<div class="row">
				<div class="col-md-12 col-sm-12 col-xs-12 form-group">
					<label class="labeltext labelpadding">Program type</label><br>
					 <div class="slds-form-element">
					  <div class="slds-form-element__control">
					    <span class="slds-checkbox">
					      <input type="checkbox" name="options" id="CIP" value="CIP" />
					      <label class="slds-checkbox__label" for="CIP">
					        <span class="slds-checkbox_faux customfaux"></span>
					        <span class="slds-form-element__label customLabel">CIP</span>
					      </label>
					    </span>
					  </div>
					</div>
				</div>
				<div class="col-md-12 col-sm-12 col-xs-12 form-group">
		    	    <div class="slds-form-element">
					  <div class="slds-form-element__control salesforce">
					    <span class="slds-checkbox">
					      <input type="checkbox" name="options" id="grs" value="grs" />
					      <label class="slds-checkbox__label" for="grs">
					        <span class="slds-checkbox_faux customfaux"></span>
					        <span class="slds-form-element__label customLabelGRS">Include GRS Connector</span>
					      </label>
					    </span>
					  </div>
					</div>
				</div>
			</div>
			<div class="row">
				<div class="col-md-12 buttons">
					<div class="col-md-1" >
					  	<a href="/home.html" class="backButton" a> << Back</a>
					</div>
					<div class="col-md-1 col-md-offset-10" >
						<button id ="install" class="slds-button slds-button_brand buttonBorder" onclick="checkFields()">Install</button>
					</div>
				</div>
			</div>
			</div>
		</div>
	</body>
</html>

