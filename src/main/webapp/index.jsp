<!doctype html>
<html>
 <jsp:include page="/WEB-INF/jsp/header.jsp"/>

<script>
var appName = ''
function deploy()
{
	var ref = $('#ref').val();    
	var sfdeployurl = 
		$('#production').attr('checked') ?
				'/app/home' :
				'https://sf-deployer-sandbox.herokuapp.com/app/home';
				//'/app/deploy';
	
	window.location = sfdeployurl;
}
//'https://githubsfdeploy.herokuapp.com/app/githubdeploy'
//'https://githubsfdeploy-sandbox.herokuapp.com/app/githubdeploy'
function togglebuttoncode()
{
	updatebuttonhtml();
	if($('#showbuttoncode').attr('checked') == 'checked')
		$('#buttoncodepanel').show();
	else
		$('#buttoncodepanel').hide();
}
function updatebuttonhtml()
{
	var repoOwner = $('#owner').val();
	var repoName = $('#repo').val();
	var ref = $('#ref').val();
	var buttonhtml =
		( $('#blogpaste').attr('checked') == 'checked' ? 
			'<a href="https://fielodeploy.herokuapp.com?owner=' + repoOwner +'&repo=' + repoName + (ref!='' ? '&ref=' + ref : '') + '">\n' :
			'<a href="https://fielodeploy.herokuapp.com">\n') +					
			'  <img alt="Deploy to Salesforce"\n' +
			'       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">\n' +	//TODO: use local version
		'</a>';
	$('#buttonhtml').text(buttonhtml);
}
function load()
{
	// Default from URL
	var owner = $.url().param('owner');
	var repo = $.url().param('repo');
	var ref = $.url().param('ref');

	// Check for GitHub referrer?			
	if(owner==null && repo==null) {
		var referrer = document.referrer;
		// Note this is not passed from private repos or to http://localhost
		// https://github.com/afawcett/githubdeploytest
		if(referrer!=null && referrer.startsWith('https://github.com')) {		
			var parts = referrer.split('/');
			if(parts.length >= 5) {
				owner = parts[3];
				repo = parts[4];
			}
			if(parts.length >= 7) {
			    // Branch/Tag/Release?
                // https://github.com/afawcett/githubdeploytest/tree/BranchA
                // https://github.com/afawcett/githubdeploytest/tree/Branch/B
			    if(parts[5] == 'tree') {
			        ref = referrer.substr(referrer.indexOf('/tree/')+6);
			    }
			}
		}		
	}
	
	// Default fields
	$('#owner').val(owner);
	$('#repo').val(repo);
	$('#ref').val(ref);
	
	
	$('#login').focus();
	updatebuttonhtml();
}
</script>

<body class="bodycolor" onload="load();">
	<form onsubmit="loginToSalesforce();return false;">
		<div id ="container" class="container">
			<div class="row">
				<div class="col-md-11 col-md-offset-1">
					<div class="login-title">Welcome to Fielo Custom Program Installation</div>
				</div>
				<div class="col-md-8 col-md-offset-4">
					<button class="slds-button slds-button_brand buttonLogin" onclick="deploy();return false;">Proceed to login</button>
				</div>
				<div class="col-md-10 col-md-offset-2 col-sm-12 col-xs-12 form-group" style="display:none">
					<fieldset class="slds-form-element">
		                  <label class="labeltext labelpaddingLogin">Deploy with:</label>
		                  <div class="slds-form-element__control">
		                     <span class="slds-radio">
		                     <input type="radio" id="production" name="environment" checked="checked" value="production"/>
		                     <label class="slds-radio__label radioInline" for="environment">
		                     <span class="slds-radio_faux customfauxRadio"></span>
		                     <span class="slds-form-element__label customLabel">Production/Development</span>
		                     </label>
		                     </span>
		                     <span class="slds-radio">
		                     <input type="radio" id="sandbox" name="environment" value="sandbox"/>
		                     <label class="slds-radio__label radioInline" for="environment">
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
	<img src="/resources/img/lightning_blue_background.png" alt="" style =" height: 360px; width: 100%;">
</body>
</html>