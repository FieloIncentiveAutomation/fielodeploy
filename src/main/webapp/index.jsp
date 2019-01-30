<!doctype html>
<html>
 <jsp:include page="/WEB-INF/jsp/header.jsp"/>

<script>
var appName = ''
function deploy()
{
	var ref = $('#ref').val();    
	var sfdeployurl = 
		$('#production').is(':checked') ?
				/*'app/home' :*/
				'https://sf-deployer.herokuapp.com/app/home':
				'https://sf-deployer-sandbox.herokuapp.com/app/home';
				//'/app/deploy';
	
	window.location = sfdeployurl;
}
//'https://githubsfdeploy.herokuapp.com/app/githubdeploy'
//'https://githubsfdeploy-sandbox.herokuapp.com/app/githubdeploy'

</script>

<body class="bodycolor">
	<form onsubmit="loginToSalesforce();return false;">
		<div id ="container" class="container">
			<div class="row">
				<div class="col-md-11 col-md-offset-1">
					<div class="login-title">Welcome to Fielo Custom Program Installation</div>
				</div>
				<div class="col-md-8 col-md-offset-4">
					<button class="slds-button slds-button_brand buttonLogin" onclick="deploy();return false;">Proceed to login</button>
				</div>
				<div class="col-md-10 col-md-offset-2 col-sm-12 col-xs-12 form-group">
					<fieldset class="slds-form-element">
						<label class="labeltext labelpaddingLogin">Deploy with:</label>
						<div class="slds-form-element__control">
					         <span class="slds-radio">
						          <input type="radio" id="production" name="environment" checked="checked" value="production"/>
						          <label class="slds-radio__label radioInline" for="production">
							           <span class="slds-radio_faux customfauxRadio"></span>
							           <span class="slds-form-element__label customLabel">Production/Development</span>
						          </label>
					         </span>
					         <span class="slds-radio">
						          <input type="radio" id="sandbox" name="environment" value="sandbox"/>
						          <label class="slds-radio__label radioInline" for="sandbox">
							           <span class="slds-radio_faux customfauxRadio"></span>
							           <span class="slds-form-element__label customLabel">Sandbox</span>
						          </label>
					         </span>
						</div>
	               </fieldset>
	            </div>
			</div>
		</div>
	</form>
	<img src="resources/img/lightning_blue_background.png" alt="" style =" height: 360px; width: 100%;">
</body>
</html>