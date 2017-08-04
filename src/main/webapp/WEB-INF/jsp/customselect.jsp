<!doctype html>
<html>
<head>
    <title>Fielo Deployment Tool</title>
	<script src="/fielodeploy/resources/js/jquery-1.7.1.min.js"></script>
	<script src="/fielodeploy/resources/js/purl.js"></script>
	<link rel="stylesheet" type="text/css" href="/fielodeploy/resources/assets/styles/salesforce-lightning-design-system.css">
</head>

<script>
var appName = '';
function continueRedirect()
{
	var ref = $('#ref').val();    
	var continueUrl =
		$('#app').attr('checked') ?
			'/fielodeploy/app/githubdeploy/deploy' :
			'/fielodeploy/app/githubdeploy/deploy';
	
	//sfdeployurl+= '/' + 'deploy';
	window.location = continueUrl;
}


</script>

	<body style="margin:10px" onload="load();">
		
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
			      	    <input type="submit" id="continue" value="Continue" class="slds-button slds-button--neutral" onclick="continueRedirect();return false;"/>
			        </div>
			    </div>				
			</div>
		</div>
			&nbsp;
		
			<div id="reposDiv" class="slds-form--horizontal">
				
				
				
				<!-- <div class="slds-form-element">
					<legend class="form-element__legend slds-form-element__label">Select components to install:</legend>
					<div id="repos" class="slds-form-element__control">
						<!-- <label class="slds-radio">
							<input type="radio" id="programs" name="environment" value="app">
							<span class="slds-radio--faux"></span>
							<span class="slds-form-element__label">App1</span>
						</label>-->
						<!-- <label class="slds-radio">
							<input type="radio" id="custom" name="environment" checked="true" value="custom">
							<span class="slds-radio--faux"></span>
							<span class="slds-form-element__label">Custom</span>
						</label>-->
					<!-- </div>
				</div>-->

<script src="/fielodeploy/resources/js/jquery-1.7.1.min.js"></script>
<c:if test="${reposList != null}">
	<script type="text/javascript">

		var GitHubDeploy = {

			// Contents of the GitHub repository
			reposList: ${reposList},
			
			reposMap: ${reposMap},

			// Render GitHub repository contents
			render: function(list, map) {
				[].forEach.call(list, function(repo){
					//for(repo in list)
					//alert(repo);
					
					var htmlString = '<div class="slds-form-element"><legend class="form-element__legend slds-form-element__label">' + repo + '</legend>' +
					'<div id="repos" class="slds-form-element__control">';
					
					for(fileIdx in map[repo])
						htmlString += '<label class="slds-checkbox"><input type="checkbox" id="' + map[repo][fileIdx].fullName + '" name="environment" value="' + map[repo][fileIdx].fullName + '">' +
								'<span class="slds-checkbox--faux"></span>' +
								'<span class="slds-form-element__label">' + map[repo][fileIdx].name + '</span></label>';
						
					htmlString += '</div></div>';
					$('#reposDiv').append(htmlString);
				})
			}		
		}
		
		// Render files selected to deploy
		GitHubDeploy.render(GitHubDeploy.reposList, GitHubDeploy.reposMap);

	</script>
</c:if>
	</body>
	</body>
</html>