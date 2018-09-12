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
								    <div class="slds-dropdown slds-dropdown_left slds-dropdown_length-5 slds-dropdown_medium">
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
					              	 <button id="deploy" class="slds-button slds-button_brand buttonBorder" onclick="GitHubDeploy.initDeploy(GitHubDeploy.deployList);">Install</button>
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
		
		 	 <!-- Modal content -->
			 <div class="modal-content modal-content-longer">
				 <!-- Progress Modal Header -->
			    <div class="modal-header progressModal headerProgressModal">
			      <p>Installing...</p>
			    </div>
			    <!-- Complete Modal Header -->
			    <div class="modal-header completeModal headerCompleteModal">
			      <p>Complete</p>
			    </div>
			     <!-- Alert Modal Header -->
			    <div class="modal-header alertModal">
			      <p>Alert</p>
			    </div>
			    <div id ="modalbody" class="modal-body">	
					<div id="rowModalBody" class="row">		
							<!-- Progress Modal -->    	
							<!-- 
				   		<div class="col-md-12 col-sm-12 col-xs-12 progressModal">
						  <div class="slds-grid slds-grid_align-spread slds-p-bottom_x-small" id="progress-bar-label-id-7">
						    <span aria-hidden="true">
						      <strong id="progressbarInfo" >0% Complete</strong>
						    </span>
						  </div>
						  <div class="slds-progress-bar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0" aria-labelledby="progress-bar-label-id-7" role="progressbar">
						    <span id="progressbar" class="slds-progress-bar__value" style="width: 0%;">
						      <span class="slds-assistive-text">Progress: 0%</span>
						    </span>
						  </div>
				   		</div>
				   		 -->	
				   		
				   		
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
			                  YOUR PLT VERSION IS OLD AND THE INSTALLATION OF THIS BEHAVIOR REQUIRES THE UPGRADE OF FIELO PLT. THIS UGRADE MAY CAUSE PROBLEMS WITH THE CURRENT CUSTOMIZATION IN YOUR ORG. PLEASE CONTACT THE ADMINISTRATION AND AGREE TO CONTINUE THE INSTALLATION
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
						    var packages =  '<li class="slds-dropdown__item">' 							 +
				              '<a href="javascript:void(0);" role="menuitem" tabindex="0">' 							 +
				                  '<span class="slds-truncate infoPackageLabel">Package</span><span class="slds-truncate infoPackageLabel">Version</span>' +
				              '</a>' 																					 +
			               '</li>';
							for(fileIdx in container) {
								 packages = packages +
					        	  '<li class="slds-dropdown__item">' +
					              '<a href="javascript:void(0);" role="menuitem" tabindex="0">' +
					                  '<span class="slds-truncate infoPackageDescription">'+ container[fileIdx].name  +'</span>' + '<span class="slds-truncate infoPackageDescription">' + ((container[fileIdx].version != null) ? container[fileIdx].version : 'master') +'</span>' +
					              '</a></li>';
					              
								if (first) {
									deploy = '';
									first = false;
								} else {
									deploy = '<br>';
								}
								$('#dropdownInfo').empty();
								$('#dropdownInfo').append(packages);
							}
							
						},
						
					// Start deploys
					initDeploy: function(container) {
						
						$('#deploystatus').empty();
						$('#openInfoPackages').removeClass('slds-is-open');
			            $('#openInfoPackages').addClass('slds-is-closed');
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
			            /*$.getJSON('/fielodeploy/deploys.json', function(config) {
			            	var deploys = [];
			            	$.each(config,function(key, value){
			            		deploys.push(value);
			            		//alert(value.version);
			            	});
			            	deploys.reverse();
							GitHubDeploy.packages = deploys;           	
							if(GitHubDeploy.packages.length > 0)
								GitHubDeploy.deploy();
							});*/
						},				
						
					// Control deploys
					deploy: function() {
							//console.log(GitHubDeploy.packages.length);
							minPercentage = 0;
							maxPercentage = 100;
							var value = GitHubDeploy.packages.pop();
							valueAlert = value;
							//console.log('Packages para instalar');
							//console.log(GitHubDeploy.packages);
							
							$('#rowModalBody').append(getProgressBar(valueAlert.name));
							$('.progressModal').show();
							//console.log(value);
							//var value = pack[0];
							//var repoData = pack[1];
							//alert(GitHubDeploy.packages.length);
							//alert(name);
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
							
							//alert(repoOwner);
							//alert(repoName);
							//alert(ref);
							$('#deploy').attr('disabled', 'disabled');
							/////$('#deploystatus').empty();
							//$('#deploystatus').show();
							//$('#deploystatus').append('<div>Repository Deployment Started: ' + repoName + '</div>');
							//$('#deploystatus').append('<div>Status: Connecting</div>');
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
				                    //alert('Failed ' + textStatus + errorThrown);
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
							
							
							//$('#rowModalBody').prepend(getProgressBar());
							//$('.progressModal').show();
							//$('#deploy').attr('disabled', 'disabled');
							/////$('#deploystatus').empty();
							//$('#deploystatus').show();
							//$('#deploystatus').append('<div>Package Deployment Started: ' + packageName + '</div>');
							//$('#deploystatus').append('<div>Status: Connecting</div>');
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
				                    	//console.log('chegou deploypackage');
				                    	//frame(++minPercentage, maxPercentage);
				                    	GitHubDeploy.intervalId = window.setInterval(GitHubDeploy.checkStatus, 5000);
				                    	
				                    }
				                },
				                error: function(jqXHR, textStatus, errorThrown) {
				                    alert('Failed with status: ' + jqXHR.status + '\n\n' + $(jqXHR.responseText).filter('h1').text());
									//$('#deploy').attr('disabled', null);
				                    //$('#deploystatus').append(jqXHR.responseText);
				                    //alert('Failed ' + textStatus + errorThrown);
				                }
				            });
						},		
						
						// Render Async
						renderAsync: function() {
								//$('div:last-child', '#deploystatus').remove();
								var completed = (GitHubDeploy.asyncResult.state == 'Completed');
								if (completed) {
									GitHubDeploy.dots = 0;
								}
								/*
								$('#deploystatus').append(
									'<div>Status: '+
										GitHubDeploy.asyncResult.state + '.'.repeat(GitHubDeploy.dots) +
										(GitHubDeploy.asyncResult.message != null ? GitHubDeploy.asyncResult.message : '') + 
									'</div>');
								*/
								// GitHubDeploy.dots - [0..3]
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
						/*
							$('div:last-child', '#deploystatus').remove();
							$('#deploystatus').append('<div>Deployment Complete</div>');
							$('#deploystatus').append('<div>=======================================</div>');					
							$('#deploy').attr('disabled', null);
							*/
							//var errors = false;
				            $.ajax({
				                type: 'GET',
				                url: window.location.pathname + '/checkdeploy/' + GitHubDeploy.asyncResult.id,
				                contentType : 'application/json; charset=utf-8',
				                dataType : 'json',
				                success: function(data, textStatus, jqXHR) {
				                	var newerVersionText = 'A newer version of this package is currently installed';
				                	var newerVersionTextPT = 'Uma versão mais recente deste pacote está instalada.';
				                	
				                	var hasNewerVersion = (data.indexOf(newerVersionText) != -1);
				                	var hasNewerVersionPT = (data.indexOf(newerVersionTextPT) != -1);	
				                	//console.log(data.indexOf(newerVersionText));
				                	if (data.substr(1, 9) == 'Failures:' && (!hasNewerVersion && !hasNewerVersionPT)) {
				                		//alert('Deployment error!');
				                		//console.log(valueAlert);
				                		//maxPercentage = Math.floor(Math.random() * 21) + 70;
				                		flagError = 1;
				                		var msgFailures =  'Deployment Error. We were not able to install '+ valueAlert.name+ ' version:'+ valueAlert.version;
				                		$('#' + valueAlert.name).prepend(getAlert(msgFailures, 'error')); 
				                		//console.log('entrou falha');
				                		console.log(data);			                	
				                		closeButton();
					                	GitHubDeploy.packages = [];   
										$('.headerProgressModal').hide();
										$('.headerCompleteModal').fadeIn("slow");
										$('#rowModalBody').append('<div class="col-md-10 col-md-offset-4" style="margin-top: 15px;padding-left: 35px;">' +
																	'<button id="deployFinal" class="slds-button slds-button_brand buttonComplete" onclick="goBack();">Back</button>' + 
																	  '</div>');

					                }
				                	if (hasNewerVersion || hasNewerVersionPT) {
				                		//maxPercentage = Math.floor(Math.random() * 21) + 70;
				                		var msghasNewerVersion = valueAlert.name + ' version:'+ valueAlert.version +' will not be installed because there is already a newer version installed in your org.';
				                		$('#' + valueAlert.name).prepend(getAlert(msghasNewerVersion, 'warning'));
				                		//console.log('entrou aqui');
					                	closeButton();
									//	$('#deploystatus').append('<div>=======================================</div>');					
				                	} else 
				                		
				                	if (data.substr(1, 9) != 'Failures:' && (!hasNewerVersion && !hasNewerVersionPT))
			                			{
					                		while (minPercentage < maxPercentage){       		
				                    			 frame(valueAlert.name, ++minPercentage);
					                    	  }
			                			}
									if(GitHubDeploy.packages.length > 0){	
										GitHubDeploy.deploy();	  
									}
									else{
										if(flagError ==0){
								
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