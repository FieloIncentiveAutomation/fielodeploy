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
			<div class="row">
				<div class="col-md-12">
					<p class="header1-padding h1 "><img src="static/salesforce/assets/icons/utility/settings.svg" alt="Fielo Plataform Logo" class="icon"> Welcome to Fielo Custom Program Installation </p>
					<p class="header2-padding h2 ">What do you want to install?</p>
				</div>
			    <div class="col-sm-6">			
					<div class="borderbox">
						<div class ="square">
					      <img src="static/img/fielologo.png" alt="Fielo Plataform Logo" class="img">
					    </div>
					</div>
				</div>
				<div class="col-sm-6">	
					<div class="borderbox">
					    <div class ="square">
					        <img src="static/img/salesforcelogo.png" alt="Salesforce Logo" class="img">
					      	<div class="slds-form-element">
								<div class="slds-form-element__control">
									<span class="slds-checkbox">
									  <input type="checkbox" name="options" id="checkboxSalesCommunities" value="checkboxSalesCommunities" />
									  <label class="slds-checkbox__label" for="checkboxSalesCommunities">
									    <span class="slds-checkbox_faux customfaux"></span>
									    <span class="slds-form-element__label customLabelHome">Salesforce Communities</span>
									  </label>
									</span>
								</div>
							</div>
	                    </div>
				  	</div>
				</div>
			</div>
			<div class="col-md-12 buttons">
				<div class="col-md-1" ></div>
				<div class="col-md-1 col-md-offset-10" >
					<button id ="nextButton" class="slds-button slds-button_brand buttonBorder" onclick="window.location.href='/customize.html'">Next</button>
				</div>
			</div>
		</div>
	</body>
</html>