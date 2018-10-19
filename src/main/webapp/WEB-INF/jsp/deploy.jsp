<%@taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!DOCTYPE html>
<html>
   <jsp:include page="header.jsp"/>
   
   <body bgcolor="#ffffff">
		<div class="container">
			<div class="row">
			   <div class="col-md-12">
			      <p class="header1-padding h1 "><img src="resources/assets/icons/utility/settings.svg" alt="Fielo Plataform Logo" class="icon"> Welcome to Fielo Custom Program Installation </p>
			   </div>
			</div>
			<div id="confirmDetails">
				<div>
					<div class="modal-header">
				      <p>Confirm details</p>
				    </div>
				    <div class="modal-body">	
						<div class="row">		
							<!-- Info Modal -->  
							<div class="col-md-12 col-sm-12 col-xs-12">
								<div id ="openInfoPackages" class="slds-dropdown-trigger slds-dropdown-trigger_click slds-is-closed">
								    <button class="slds-button slds-button_icon slds-button_icon-border-filled" aria-haspopup="true" title="Show More">
								        <svg class="slds-button__icon" aria-hidden="true">
								            <use xlink:href="resources/assets/icons/utility-sprite/svg/symbols.svg#down"></use>
								        </svg>
								        <span class="slds-assistive-text">Show More</span>
								    </button>
								    <div class="slds-dropdown slds-dropdown_left slds-dropdown_length-5 slds-dropdown_large">
								        <ul id="dropdownInfo" class="slds-dropdown__list" role="menu" aria-label="Show More">
								        </ul>
								    </div>
								</div>
						   		<dl class="slds-list_stacked">
								  <dt class="slds-item_label slds-text-color_weak slds-truncate modal-label" title="To">To</dt>
								  <dd class="slds-item_detail slds-truncate modal-description" title="Salesforce Org">Salesforce Org</dd>
								  <dt class="slds-item_label slds-text-color_weak slds-truncate modal-label" title="Organization">Organization</dt>
								  <dd id ="organizationDescription" class="slds-item_detail slds-truncate modal-description" title="Organization Description"><c:out value="${userContext.getOrganizationName()}" /></dd>
								  <dt class="slds-item_label slds-text-color_weak slds-truncate modal-label" title="User">User</dt>
								  <dd id ="userDescription" class="slds-item_detail slds-truncate modal-description" title="User Description" ><c:out value="${userContext.getUserName()}" /></dd>
								</dl>
							</div>
							<div class="col-md-12 col-sm-12 col-xs-12 buttons infoModal">
					            <div class="col-md-1 col-sm-6 col-xs-6" style="padding-left: 0px;">
					            	 <button id="back" class="slds-button slds-button_brand buttonBorder"  onclick="goBack()">Back</button>
					            </div>
					            <div class="col-md-1 col-md-offset-10 col-sm-6 col-xs-6" style="padding-right: 0px;">
					              	 <button id="deploy" class="slds-button slds-button_brand buttonBorder">Install</button>
					            </div>
					        </div>
					   	</div>
					</div>  
				</div>  
			</div>
		
			<!-- The Modal -->
			<div id="myModal" class="modal">
			<c:if test="${error != null}">
				<div class="slds-notify_container">
					<div class="slds-notify slds-notify--alert slds-theme--alert-texture" role="alert">
						<h2>${error}</h2>
					</div>
				</div>
			</c:if>
		
		 	 <!-- Modal content Deploy -->
			 <div class="modal-content modal-content-longer">
				 <!-- Progress Modal Header -->
			    <div class="modal-header progressModal headerProgressModal">
			      <p>Installing...</p>
			    </div>
			    <!-- Complete Modal Header -->
			    <div class="modal-header completeModal headerCompleteModal">
			      <p>Complete</p>
			    </div>
			    <div id ="modalbody" class="modal-body">	
					<div id="rowModalBody" class="row">					   		
				   	</div>
				</div>  
			</div>
			
			<!-- Modal content for the alert-->
			 <div class="modal-content alertModal">
			     <!-- Alert Modal Header -->
			    <div class="modal-header alertModal">
			      <p>Alert</p>
			    </div>
			    <div class="modal-body">	
					<div class="row">		
				   		<!-- Alert Modal -->
				   		<div class="col-md-12 col-sm-12 col-xs-12 alertModal">
			               <div id ="alertFielo" class="slds-notify slds-notify_alert slds-theme_alert-texture slds-theme_warning alert bodyAlert" role="alert">
			                  <span class="slds-assistive-text">warning</span>
			                  <span class="slds-icon_container slds-icon-utility-warning slds-m-right_x-small icon-left" title="Description of icon when needed">
			                     <svg class="slds-icon slds-icon_x-small iconAlert" aria-hidden="true">
			                        <use xlink:href="resources/assets/icons/utility-sprite/svg/symbols.svg#warning"></use>
			                     </svg>
			                  </span>
			                  <span class="customAlert">
			                   THE FOLLOWING PACKAGE(S) ARE OUT OF DATE:<br>
			                   <br>
			                  - FIELO PLATFORM
							  <br>
							  <br>
			                  THIS UPGRADE MAY REQUIRE MANUAL STEPS AND/OR CAUSE PROBLEMS WITH THE CURRENT CUSTOMIZATIONS IN YOUR ORG. PLEASE CONSULT YOUR SYSTEM ADMINISTRATOR BEFORE CONTINUING INSTALLATION.
			                  </span>
			               </div>
				   		</div>
				   		<div class="col-md-6 col-sm-12 col-xs-12 alertModal">
					   		<button id="cancelDeploy" class="slds-button slds-button_brand buttonComplete">Cancel</button>
						</div>
						<div class="col-md-6 col-sm-12 col-xs-12 alertModal">
							<button id="continueDeploy" class="slds-button slds-button_brand buttonComplete">Ok, continue</button>	
						</div>
				   	</div>
				</div>  
			</div>
		</div>
		<!--  Loading Spinner -->
		<div class="demo-only" style="height: 6rem; display:none;">
		  <div role="status" class="slds-spinner slds-spinner_large slds-spinner_brand">
		    <span class="slds-assistive-text">Loading</span>
		    <div class="slds-spinner__dot-a"></div>
		    <div class="slds-spinner__dot-b"></div>
		  </div>
		</div>
	</div>

		<c:if test="${githubcontents != null}">
			<pre id="deploystatus"  style="display: none;"></pre>
			<div id="githubcontents"></div>
		</c:if>

		<script src="resources/js/jquery-1.7.1.min.js"></script>
		<c:if test="${githubcontents != null}">
			<script type="text/javascript">
			
				// Number of packages to be install
				var maxPackage = 0; 
				var minPackage = 0; 
				var minPercentage = 0;
				var maxPercentage = 100;
				var valueAlert = 'teste';
				var flagError = 0;
				var GitHubDeploy = {
		
					// Contents of the GitHub repository
					contents: ${githubcontents},
					
					// Contents to deploy
					deployList: ${deployList},
		
					// Async result from Salesforce Metadata API
					asyncResult : null,
		
					// Client timer Id used to poll Salesforce Metadata API
					intervalId : null,
					
					// Number of deploys
					deploys: null,
					
					// Packages to deploy
					packages: null,
		
					// Dots for showing status progress
					dots: 0,
					
					// Render GitHub repository contents
					render: function(container) {
							if(container.repositoryItem!=null)
								$('#githubcontents').append(
									'<div><a target="_new" href="${repo.getHtmlUrl()}/blob/${ref}/' +
										container.repositoryItem.path + '">' + container.repositoryItem.path + '</a></div>');
							for(fileIdx in container.repositoryItems)
								if(container.repositoryItems[fileIdx].repositoryItem.type == 'dir')
									GitHubDeploy.render(container.repositoryItems[fileIdx]);
								else
									$('#githubcontents').append(
										'<div><a target="_new" href="${repo.getHtmlUrl()}/blob/${ref}/' +
											container.repositoryItems[fileIdx].repositoryItem.path + '">' +
											container.repositoryItems[fileIdx].repositoryItem.path + '</a></div>');
						},		
					
		
					// Render deployment list
					renderDeployList: function(container) {
						
							var deploy;
							var isRepo;
							var first = true;
							var packages =  "";
							var countPackages = 0;
							var countRepositories = 0;
							//Count number of packages in the list
							$.each(container, function(i, v) {
							    if (v.type == "package") {
							    	countPackages ++;
							    }
							});
							//Count number of repositories in the list
							$.each(container, function(i, v) {
							    if (v.type == "repository") {
							    	countRepositories ++;
							    }
							});

							if (countPackages> 0){
								console.log('entrou');
								packages +=  '<li class="slds-dropdown__item">' 	 +
						              '<a href="javascript:void(0);" role="menuitem" tabindex="0">' 	 +				
						                  '<span class="slds-truncate infoPackageLabel">Package</span><span class="slds-truncate infoPackageLabel">Version</span>' +
						              '</a>' +												
			              		 	'</li>';
								for(fileIdx in container) {
									if (container[fileIdx].type == "package"){
										 packages +=  '<li class="slds-dropdown__item">' +
							              '<a href="javascript:void(0);" role="menuitem" tabindex="0">' +
							                  '<span class="slds-truncate infoPackageDescription">'+ container[fileIdx].name +'</span>' + '<span class="slds-truncate infoPackageDescription">' + ((container[fileIdx].version != null) ? container[fileIdx].version : 'master')  +'</span>' +
							                  '</a>' +
						             	 '</li>';
										}
								}
								
							}
							
							
							    	  
							    
							    
							if (countRepositories> 0){
							    packages +=  '<br><li class="slds-dropdown__item">' 							 +
					              '<a href="javascript:void(0);" role="menuitem" tabindex="0">' 							 +
					                  '<span class="slds-truncate infoPackageLabel">Repository</span><span class="slds-truncate infoPackageLabel">Version</span>' +
					              '</a>' 																					 +
				               '</li>';
								for(fileIdx in container) {
									if (container[fileIdx].type != "package"){
										 packages = packages +
							        	  '<li class="slds-dropdown__item">' +
							              '<a href="javascript:void(0);" role="menuitem" tabindex="0">' +
							                  '<span class="slds-truncate infoPackageDescription">'+ container[fileIdx].name  +'</span>' + '<span class="slds-truncate infoPackageDescription">' + ((container[fileIdx].version != null) ? container[fileIdx].version : 'master') +'</span>' +
							              '</a></li>';
							              
									}
								}
							}
							$('#dropdownInfo').empty();
							$('#dropdownInfo').append(packages);
							
						},
						
					// Start deploys
					initDeploy: function(container) {
						
						$('#deploystatus').empty();
						$('#openInfoPackages').removeClass('slds-is-open');
			            $('#openInfoPackages').addClass('slds-is-closed');
			            $('.modal-content-longer').show();
		            	var deploys = [];
		            	$.each(container,function(key, value){
		            		deploys.push(value);
		            		//alert(value.version);
		            	});
		            	deploys.reverse();
						GitHubDeploy.packages = deploys;
						
						maxPackage = GitHubDeploy.packages.length;
						if(GitHubDeploy.packages.length > 0){
							GitHubDeploy.deploy();
						}
						},				
						
					// Control deploys
					deploy: function() {
							minPercentage = 0;
							maxPercentage = 100;
							var value = GitHubDeploy.packages.pop();
							valueAlert = value;

							
							$('#rowModalBody').append(getProgressBar(valueAlert.name));
							
							$('.progress').show();
							$('.progressModal').show();
							if(value.repoOwner == null)
								GitHubDeploy.deployPackage(value.name, value.version);
							else {
								//alert(repoOwner);
								var ref = (value.version == null ? 'master' : value.version);
								//alert(ref);
								GitHubDeploy.deployRepository(value.repoOwner, value.name, ref);
							}
						},
		
					// Deploy from Git repository
					deployRepository: function(repoOwner, repoName, ref) {
							$('#deploy').attr('disabled', 'disabled');
				            $.ajax({
				                type: 'POST',
				                url: window.location.pathname + '/' + repoOwner + '/' + repoName + '/' + ref, // + (ref!='' ? '&ref=' + ref : ''),
				                processData : false,
				                data : JSON.stringify(GitHubDeploy.contents),
				                contentType : 'application/json; charset=utf-8',
				                dataType : 'json',
				                success: function(data, textStatus, jqXHR) {
				                    GitHubDeploy.asyncResult = data;
				                    GitHubDeploy.renderAsync();
				                    if(GitHubDeploy.asyncResult.state == 'Completed')
				                    	GitHubDeploy.checkDeploy();
				                    else
				                    	GitHubDeploy.intervalId = window.setInterval(GitHubDeploy.checkStatus, 5000);
				                },
				                error: function(jqXHR, textStatus, errorThrown) {
				                    alert('Failed with status: ' + jqXHR.status + '\n\n' + $(jqXHR.responseText).filter('h1').text());
									$('#deploy').attr('disabled', null);                    
				                }
				            });
						},
		
					// Deploy managed package
					deployPackage: function(packageName, packageVersion ) {
							//alert(packageVersion);
							maxPercentage = calcPercentage(++minPackage, maxPackage);
							 // Get the modal
							var modal = document.getElementById('myModal');
							modal.style.display = "block";
				            $.ajax({
				                type: 'POST',
				                url: window.location.pathname + '/' + packageName + '/' + packageVersion,
				                processData : false,
				                data : JSON.stringify(GitHubDeploy.contents),
				                contentType : "application/json; charset=utf-8",
				                dataType : "json",
				                success: function(data, textStatus, jqXHR) {
				                    GitHubDeploy.asyncResult = data;
				                    GitHubDeploy.renderAsync();
				                    if(GitHubDeploy.asyncResult.state == 'Completed') {
				                    	GitHubDeploy.checkDeploy();
				                    }
				                    else{
				                    	GitHubDeploy.intervalId = window.setInterval(GitHubDeploy.checkStatus, 5000);
				                    	
				                    }
				                },
				                error: function(jqXHR, textStatus, errorThrown) {
				                    alert('Failed with status: ' + jqXHR.status + '\n\n' + $(jqXHR.responseText).filter('h1').text());

				                }
				            });
						},		
						
						// Render Async
						renderAsync: function() {
								
								var completed = (GitHubDeploy.asyncResult.state == 'Completed');
								if (completed) {
									GitHubDeploy.dots = 0;
								}
								
								if (!completed) {
									GitHubDeploy.dots = (++GitHubDeploy.dots) % 4;	
								}
							},
		
					// Check Status
					checkStatus: function() {
				            $.ajax({
				                type: 'GET',
				                url: window.location.pathname + '/checkstatus/' + GitHubDeploy.asyncResult.id,
				                contentType : 'application/json; charset=utf-8',
				                dataType : 'json',
				                success: function(data, textStatus, jqXHR) {
				                    GitHubDeploy.asyncResult = data;
				                    GitHubDeploy.renderAsync();
				                    if(GitHubDeploy.asyncResult.state == 'Completed')
				                    {	
				                    	window.clearInterval(GitHubDeploy.intervalId);
				                    	GitHubDeploy.checkDeploy();		                    	
				                    }
				                    else{
				                    	
				                    	if (minPercentage < 95){
				                    		frame(valueAlert.name, ++minPercentage);
				                    	}
				                    }     
				                },
				                error: function(jqXHR, textStatus, errorThrown) {
				                	$('#deploystatus').append('<div>Error: ' + textStatus + errorThrown + '</div>');
				                }
				            });
						},
		
					// Check Deploy
					checkDeploy: function() {
				            $.ajax({
				                type: 'GET',
				                url: window.location.pathname + '/checkdeploy/' + GitHubDeploy.asyncResult.id,
				                contentType : 'application/json; charset=utf-8',
				                dataType : 'json',
				                success: function(data, textStatus, jqXHR) {
				                	console.log(data);
				                	var newerVersionText = 'A newer version of this package is currently installed';
				                	var newerVersionTextPT = 'Uma versão mais recente deste pacote está instalada.';
				                	
				                	var hasNewerVersion = (data.indexOf(newerVersionText) != -1);
				                	var hasNewerVersionPT = (data.indexOf(newerVersionTextPT) != -1);	
				                	if (data.substr(1, 9) == 'Failures:' && (!hasNewerVersion && !hasNewerVersionPT)) {
				                		flagError = 1;
				                		var msgFailures =  'Deployment Error. We were not able to install '+ valueAlert.name+ ' version:'+ valueAlert.version;
				                		$('#' + valueAlert.name).prepend(getAlert(msgFailures, 'error')); 		                	
				                		closeButton();
					                	GitHubDeploy.packages = [];   
										$('.headerProgressModal').hide();
										$('.headerCompleteModal').fadeIn("slow");
										$('#rowModalBody').append('<div class="col-md-10 col-md-offset-4" style="margin-top: 15px;padding-left: 35px;">' +
																	'<button id="deployFinal" class="slds-button slds-button_brand buttonComplete" onclick="goBack();">Back</button>' + 
																	  '</div>');

					                }
				                	if (hasNewerVersion || hasNewerVersionPT) {
				                		
				                		var msghasNewerVersion = valueAlert.name + ' version:'+ valueAlert.version +' will not be installed because there is already a newer version installed in your org.';
				                		$('#' + valueAlert.name).prepend(getAlert(msghasNewerVersion, 'warning'));
					                	closeButton();
									
				                	}  
				                	if (data.substr(1, 9) != 'Failures:' && (!hasNewerVersion && !hasNewerVersionPT))
			                			{   		
				                    		frame(valueAlert.name, 100);	 
			                			}
									if(GitHubDeploy.packages.length > 0){	
										GitHubDeploy.deploy();	  
									}
									else{
										if(flagError == 0){
								
											$('.headerProgressModal').hide();
											$('.headerCompleteModal').fadeIn("slow");
											$('#rowModalBody').append('<div class="col-md-10 col-md-offset-4" style="margin-top: 15px;padding-left: 35px;">' +
																		'<button id="deployFinal" class="slds-button slds-button_brand buttonComplete" onclick="redirectOrg();">Go to Org</button>' + 
																		  '</div>');
										}
									}
				                },
				                error: function(jqXHR, textStatus, errorThrown) {
				                	$('#deploystatus').append('<div>Error: ' + textStatus + errorThrown + '</div>');
				                }
				            });
						}
				}
		
				// Render files selected to deploy
				GitHubDeploy.render(GitHubDeploy.contents);
				
				GitHubDeploy.renderDeployList(GitHubDeploy.deployList);
		
			</script>
		</c:if>
   </body>
</html>