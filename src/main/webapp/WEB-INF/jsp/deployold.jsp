<%@taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<jsp:include page="header.jsp"/>
	    <c:if test="${githubcontents != null}">
	   	<div class="slds-col slds-no-flex slds-align-bottom">
	      <div class="slds-button-group" role="group">    
	        <button id="deploy" class="slds-button slds-button--neutral" onclick="GitHubDeploy.initDeploy(GitHubDeploy.deployList);">Deploy</button>
	      </div>
	    </div>		
	    </c:if>
	</div>
</div>


<c:if test="${error != null}">
	<div class="slds-notify_container">
		<div class="slds-notify slds-notify--alert slds-theme--alert-texture" role="alert">
			<h2>${error}</h2>
		</div>
	</div>
</c:if>
&nbsp;

<!-- -->
<div class="slds-card">
	<div class="slds-card__header slds-grid">
		<div class="slds-media slds-media--center slds-has-flexi-truncate">
			<div class="slds-media__figure">
				<svg aria-hidden="true"
					class="slds-icon slds-icon-action-share slds-icon--small">
            	<use
						xlink:href="resources/assets/icons/action-sprite/svg/symbols.svg#share"></use>
          	</svg>
			</div>
			<div class="slds-media__body">
				<h2 class="slds-text-heading--small slds-truncate">Deployment List</h2>
			</div>
		</div>
	</div>
	<div class="slds-card__body">
		<ul>
			<li class="slds-tile slds-hint-parent">
				<div class="slds-tile__detail">
					<dl class="slds-dl--horizontal slds-text-body--small">
						<c:if test="${githuburl != null}">
							<dt class="slds-dl--horizontal__label">
								<p class="slds-truncate">Manage GitHub Permissions:</p>
							</dt>
							<dd class="slds-dl--horizontal__detail slds-tile__meta">
								<p class="slds-truncate">
									<a href="${githuburl}" target="_new">${githuburl}</a>
								</p>
							</dd>
						</c:if>
						<!-- dt class="slds-dl--horizontal__label">
							<p class="slds-truncate">Name:</p>
						</dt>
						<dd class="slds-dl--horizontal__detail slds-tile__meta">
							<p class="slds-truncate">${repositoryName}</p>
						</dd>
                        <dt class="slds-dl--horizontal__label">
                            <p class="slds-truncate">Branch/Tag/Commit:</p>
                        </dt>
                        <dd class="slds-dl--horizontal__detail slds-tile__meta">
                            <p class="slds-truncate">${ref}</p>
                        </dd-->                        
						<c:if test="${repo != null}">
							<dt class="slds-dl--horizontal__label">
								<p class="slds-truncate">Description:</p>
							</dt>
							<dd class="slds-dl--horizontal__detail slds-tile__meta">
								<p class="slds-truncate">${repo.getDescription()}</p>
							</dd>
							<dt class="slds-dl--horizontal__label">
								<p class="slds-truncate">URL:</p>
							</dt>
							<dd class="slds-dl--horizontal__detail slds-tile__meta">
								<p class="slds-truncate">
                                    <a href="${repo.getHtmlUrl()}/tree/${ref}" target="_new">${repo.getHtmlUrl()}/tree/${ref}</a>
								</p>
							</dd>
						</c:if>				
					</dl>
				</div>
				<c:if test="${deployList != null}">
					<div class="slds-tile__detail" id="deployList"></div>
				</c:if>
			</li>
		</ul>
	</div>
</div>
<!-- -->
<div class="slds-card">
	<div class="slds-card__header slds-grid">
		<div class="slds-media slds-media--center slds-has-flexi-truncate">
			<div class="slds-media__figure">
				<svg aria-hidden="true"
					class="slds-icon icon-utility-salesforce-1 slds-icon-text-default slds-icon--small">
            		<use
						xlink:href="resources/assets/icons/utility-sprite/svg/symbols.svg#salesforce1"></use>
          		</svg>
			</div>
			<div class="slds-media__body">
				<h2 class="slds-text-heading--small slds-truncate">To
					Salesforce Org</h2>
			</div>
		</div>
	</div>
	<div class="slds-card__body">
		<ul>
			<li class="slds-tile slds-hint-parent">
				<div class="slds-tile__detail">
					<dl class="slds-dl--horizontal slds-text-body--small">
						<dt class="slds-dl--horizontal__label">
							<p class="slds-truncate">Organization Name:</p>
						</dt>
						<dd class="slds-dl--horizontal__detail slds-tile__meta">
							<p class="slds-truncate">
								<c:out value="${userContext.getOrganizationName()}" />
							</p>
						</dd>
						<dt class="slds-dl--horizontal__label">
							<p class="slds-truncate">User Name:</p>
						</dt>
						<dd class="slds-dl--horizontal__detail slds-tile__meta">
							<p class="slds-truncate">
								<c:out value="${userContext.getUserName()}" />
							</p>
						</dd>
					</dl>
				</div>
			</li>
		</ul>
	</div>
</div>

<c:if test="${githubcontents != null}">
	<pre id="deploystatus" style="display: none"></pre>
	<div id="githubcontents"></div>
</c:if>

<script src="resources/js/jquery-1.7.1.min.js"></script>
<c:if test="${githubcontents != null}">
	<script type="text/javascript">

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
					for(fileIdx in container) {
						if (first) {
							deploy = '';
							first = false;
						} else {
							deploy = '<br>';
						}
						isRepo = (container[fileIdx].repoOwner != null);
						deploy += '<dl class="slds-dl--horizontal slds-text-body--small">';
						deploy += '<dt class="slds-dl--horizontal__label">' + 
                            	  	'<p class="slds-truncate">' + (isRepo ? 'Repository ' : 'Package ') + 'name:' + '</p></dt>' +
                            	  '<dd class="slds-dl--horizontal__detail slds-tile__meta">' +
                            	  	'<p class="slds-truncate">' + container[fileIdx].name + '</p></dd>';
						deploy += '<dt class="slds-dl--horizontal__label">' + 
                	  				'<p class="slds-truncate">' + (isRepo ? 'Owner: ' : '')  + '</p></dt>' +
                                   '<dd class="slds-dl--horizontal__detail slds-tile__meta">' +
                            	  	'<p class="slds-truncate">' + (isRepo ? container[fileIdx].repoOwner : '') + '</p></dd>';
                	  	deploy += '<dt class="slds-dl--horizontal__label">' + 
    	  							'<p class="slds-truncate">' + (isRepo ? 'Branch: ' : 'Version: ')  + '</p></dt>' +
                        		  '<dd class="slds-dl--horizontal__detail slds-tile__meta">' +
                 	  				'<p class="slds-truncate">' + ((container[fileIdx].version != null) ? container[fileIdx].version : 'master') + '</p></dd>'; 
						deploy += '</dl>';
						$('#deployList').append(deploy);
					}
				},
				
			// Start deploys
			initDeploy: function(container) {
				$('#deploystatus').empty();
            	var deploys = [];
            	$.each(container,function(key, value){
            		deploys.push(value);
            		//alert(value.version);
            	});
            	deploys.reverse();
				GitHubDeploy.packages = deploys;           	
				if(GitHubDeploy.packages.length > 0)
					GitHubDeploy.deploy();
				
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
					var value = GitHubDeploy.packages.pop();
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
					$('#deploystatus').show();
					$('#deploystatus').append('<div>Repository Deployment Started: ' + repoName + '</div>');
					$('#deploystatus').append('<div>Status: Connecting</div>');
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
		                    	GitHubDeploy.intervalId = window.setInterval(GitHubDeploy.checkStatus, 2000);
		                },
		                error: function(jqXHR, textStatus, errorThrown) {
		                    alert('Failed with status: ' + jqXHR.status + '\n\n' + $(jqXHR.responseText).filter('h1').text());
							$('#deploy').attr('disabled', null);                    
		                    //alert('Failed ' + textStatus + errorThrown);
		                }
		            });
				},

			// Deploy managed package
			deployPackage: function(packageName, packageVersion) {
					//alert(packageVersion);
					$('#deploy').attr('disabled', 'disabled');
					/////$('#deploystatus').empty();
					$('#deploystatus').show();
					$('#deploystatus').append('<div>Package Deployment Started: ' + packageName + '</div>');
					$('#deploystatus').append('<div>Status: Connecting</div>');
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
		                    else
		                    	GitHubDeploy.intervalId = window.setInterval(GitHubDeploy.checkStatus, 2000);
		                },
		                error: function(jqXHR, textStatus, errorThrown) {
		                    alert('Failed with status: ' + jqXHR.status + '\n\n' + $(jqXHR.responseText).filter('h1').text());
							$('#deploy').attr('disabled', null);
		                    //$('#deploystatus').append(jqXHR.responseText);
		                    //alert('Failed ' + textStatus + errorThrown);
		                }
		            });
				},		
				
				// Render Async
				renderAsync: function() {
						$('div:last-child', '#deploystatus').remove();
						var completed = (GitHubDeploy.asyncResult.state == 'Completed');
						if (completed) {
							GitHubDeploy.dots = 0;
						}
						$('#deploystatus').append(
							'<div>Status: '+
								GitHubDeploy.asyncResult.state + '.'.repeat(GitHubDeploy.dots) +
								(GitHubDeploy.asyncResult.message != null ? GitHubDeploy.asyncResult.message : '') + 
							'</div>');
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
		                },
		                error: function(jqXHR, textStatus, errorThrown) {
		                	$('#deploystatus').append('<div>Error: ' + textStatus + errorThrown + '</div>');
		                }
		            });
				},

			// Check Deploy
			checkDeploy: function() {
					$('div:last-child', '#deploystatus').remove();
					$('#deploystatus').append('<div>Deployment Complete</div>');
					$('#deploystatus').append('<div>=======================================</div>');					
					$('#deploy').attr('disabled', null);
					//var errors = false;
		            $.ajax({
		                type: 'GET',
		                url: window.location.pathname + '/checkdeploy/' + GitHubDeploy.asyncResult.id,
		                contentType : 'application/json; charset=utf-8',
		                dataType : 'json',
		                success: function(data, textStatus, jqXHR) {
		                	var newerVersionText = 'A newer version of this package is currently installed';
		                	var hasNewerVersion = (data.indexOf(newerVersionText) != -1);
		                	if (data.substr(1, 9) == 'Failures:' && !hasNewerVersion) {
		                		alert('Deployment error!');
			                	GitHubDeploy.packages = [];                			
			                }
		                	if (hasNewerVersion) {
			                	$('#deploystatus').append(data.replace('Failures:', 'Warning:'));  
								$('#deploystatus').append('<div>=======================================</div>');					
		                	} else {
			                	$('#deploystatus').append(data);   
		                	}
							if(GitHubDeploy.packages.length > 0)
								GitHubDeploy.deploy();	                	
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