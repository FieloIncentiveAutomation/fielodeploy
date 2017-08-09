<!doctype html>
<html>
<head>
    <title>Fielo Deployment Tool</title>
	<script src="/fielodeploy/resources/js/jquery-1.7.1.min.js"></script>
	<script src="/fielodeploy/resources/js/purl.js"></script>
	<link rel="stylesheet" type="text/css" href="/fielodeploy/resources/assets/styles/salesforce-lightning-design-system.css">
</head>

<script>
var appName = ''
function deploy()
{
	var ref = $('#ref').val();    
	var sfdeployurl =
		$('#production').attr('checked') ?
			'https://fielodeploy.herokuapp.com/app/deploy' :
				'/fielodeploy/app/home';
				//'/fielodeploy/app/deploy';
	
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

<body style="margin:10px" onload="load();">
<form onsubmit="loginToSalesforce();return false;">

<div class="slds-page-header" role="banner">
	<div class="slds-grid">
    	<div class="slds-col slds-has-flexi-truncate">
			<div class="slds-media">
				<div class="slds-media__figure">
				  <svg aria-hidden="true" class="slds-icon slds-icon-action-upload slds-icon--large slds-p-around--x-small">
				    <use xlink:href="/fielodeploy/resources/assets/icons/action-sprite/svg/symbols.svg#upload"></use>
				  </svg>
				</div>
				<div class="slds-media__body">
				  <p class="slds-page-header__title slds-truncate slds-align-middle">Fielo Deployment Tool</p>
				  <p class="slds-text-body--small slds-page-header__info">Deploying directly from installed packages or GitHub to Salesforce</p>
				</div>
			</div>			
		</div>
	   	<div class="slds-col slds-no-flex slds-align-bottom">
	      <div class="slds-button-group" role="group">
	      	<input type="submit" id="login" value="Login to Salesforce" class="slds-button slds-button--neutral" onclick="deploy();return false;"/>
	      </div>
	    </div>				
	</div>
</div>
&nbsp;
<div class="slds-form--horizontal">
<div class="slds-form-element">
	<legend class="form-element__legend slds-form-element__label">Deploy with:</legend>
	<div class="slds-form-element__control">
	<label class="slds-radio">
		<input type="radio" id="production" name="environment" value="production">
		<span class="slds-radio--faux"></span>
		<span class="slds-form-element__label">Heroku</span>
	</label>
	<label class="slds-radio">
		<input type="radio" id="sandbox" name="environment" checked="true" value="sandbox">
		<span class="slds-radio--faux"></span>
		<span class="slds-form-element__label">Local</span>
	</label>
	</div>
</div>
<!-- <div class="slds-form-element">
	<label class="slds-form-element__label">Owner:</label>
	<div class="slds-form-element__control">
		<input id="owner" oninput="updatebuttonhtml();"/>
	</div>
</div>
<div class="slds-form-element">
	<label class="slds-form-element__label">Repository:</label>
	<div class="slds-form-element__control">
	<input id="repo" oninput="updatebuttonhtml();"/>
	</div>
</div>
<div class="slds-form-element">
    <label class="slds-form-element__label">Branch/Tag/Commit:</label>
    <div class="slds-form-element__control">
    <input id="ref" oninput="updatebuttonhtml();"/>
    </div>
</div>
<div class="slds-form-element">
    <div class="slds-form-element__control">
      <label class="slds-checkbox">
        <input type="checkbox" name="options" id="showbuttoncode" onclick="togglebuttoncode();" />
        <span class="slds-checkbox--faux"></span>
        <span class="slds-form-element__label">Button Code</span>
      </label>
    </div>
</div>
</div>
<div id="buttoncodepanel" style="display:none">
	<div class="slds-form--horizontal">
		<div class="slds-form-element">
		<div class="slds-form-element__control">
			<label class="slds-checkbox">
				<input id="blogpaste" type="checkbox" onclick="updatebuttonhtml();"/>
		        <span class="slds-checkbox--faux"></span>
		        <span class="slds-form-element__label">Use Specified Owner and Repository (when not GitHub README)</span>
			</label>
		</div>
		</div>
	</div>
	<pre id="buttonhtml"></pre>
	<p><img src="/fielodeploy/resources/img/deploy.png"/></p>
</div>-->

</form>

</body>
</html>