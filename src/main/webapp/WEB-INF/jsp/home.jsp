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
               <p class="header2-padding h2 ">What do you want to install?</p>
            </div>
           
            <div class="col-sm-6">
               <div class="borderbox">
                  <div class ="square">
                     <img src="resources/img/fielotagline.png" alt="Fielo Plataform Logo" class="img-Fielo">
                        <div class="slds-form-element">
                        <div class="slds-form-element__control">
                           <span class="slds-checkbox">
                           <input type="checkbox" name="options" id="checkboxFieloPlataform" value="checkboxFieloPlataform" />
                           <label class="slds-checkbox__label" for="checkboxFieloPlataform">
                           <span class="slds-checkbox_faux customfaux"></span>
                           <span class="slds-form-element__label customLabelHome">Fielo Plataform</span>
                           </label>
                           </span>
                        </div>
                     </div>
                  </div>
               </div>
            </div>
            <div class="col-sm-6">
               <div class="borderbox">
                  <div class ="square">
                     <img src="resources/img/salesforcelogo.png" alt="Salesforce Logo" class="img">
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
            <div class="col-md-12">
               <div id ="alertOrg" class="slds-notify slds-notify_alert slds-theme_alert-texture slds-theme_warning alert bodyAlert" role="alert" style="display:none">
                  <span class="slds-assistive-text">warning</span>
                  <span class="slds-icon_container slds-icon-utility-warning slds-m-right_x-small icon-left" title="Description of icon when needed">
                     <svg class="slds-icon slds-icon_x-small iconAlert" aria-hidden="true">
                        <use xlink:href="resources/assets/icons/utility-sprite/svg/symbols.svg#warning"></use>
                     </svg>
                  </span>
                  <span class="customAlert">
                  The installation tool has detected that Communities are not enabled in your org. Before Continuing, <a href="https://support.salesforce.com/articleView?id=networks_enable.htm" target="_blank" ><strong>enable Communities</strong></a> in your org.
                  </span>
                  <button class="slds-button slds-button_icon slds-notify__close slds-button_icon-inverse" onclick="closeButtonAlertOrg();" title="Close">
                     <svg class="slds-button__icon iconAlert" aria-hidden="true">
                        <use xlink:href="resources/assets/icons/utility-sprite/svg/symbols.svg#close"></use>
                     </svg>
                     <span class="slds-assistive-text">Close</span>
                  </button>
               </div>
            </div>
         </div>
         <div class="row">
            <div class="col-md-12 col-sm-12 col-xs-12 form-group salesforce">
               <fieldset class="slds-form-element">
                  <label class="labeltext labelpadding">Licences</label><br>
                  <div class="slds-form-element__control">
                     <span class="slds-radio">
                     <input type="radio" id="customerCommunity" value="customerCommunity" name="licence"/>
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
         <div id ="incentivizes" class="row">
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
                     <input type="checkbox" name="options" id="registration" value="registration"/>
                     <label class="slds-checkbox__label checkboxInline" for="registration">
                     <span class="slds-checkbox_faux customfaux"></span>
                     <span class="slds-form-element__label customLabel">Registration</span>
                     </label>
                     </span>
                  </div>
               </div>
               <div class="slds-form-element">
                  <div class="slds-form-element__control">
                     <span class="slds-checkbox salesforceCustomer">
                     <input type="checkbox" name="options" id="salesforceLeads" value="salesforceLeads"  class="checkBoxsalesforceCustomer"/>
                     <label class="slds-checkbox__label checkboxInline" for="salesforceLeads">
                     <span class="slds-checkbox_faux customfaux"></span>
                     <span class="slds-form-element__label customLabel">Salesforce leads</span>
                     </label>
                     </span>
                  </div>
               </div>
               <div class="slds-form-element">
                  <div class="slds-form-element__control">
                     <span class="slds-checkbox salesforceCustomer">
                     <input type="checkbox" name="options" id="salesforceOpportunities" value="salesforceOpportunities" class="checkBoxsalesforceCustomer" />
                     <label class="slds-checkbox__label checkboxInline" for="salesforceOpportunities">
                     <span class="slds-checkbox_faux customfaux"></span>
                     <span class="slds-form-element__label customLabel">Salesforce opportunities</span>
                     </label>
                     </span>
                  </div>
               </div>
               <div class="slds-form-element">
                  <div class="slds-form-element__control">
                     <span class="slds-checkbox salesforceCustomer">
                     <input type="checkbox" name="options" id="salesforceOrders" value="salesforceOrders" class="checkBoxsalesforceCustomer"/>
                     <label class="slds-checkbox__label checkboxInline" for="salesforceOrders">
                     <span class="slds-checkbox_faux customfaux"></span>
                     <span class="slds-form-element__label customLabel">Salesforce orders</span>
                     </label>
                     </span>
                  </div>
               </div>
            </div>
         </div>
         <div id ="programtype" class="row">
            <div class="col-md-3 col-sm-12 col-xs-12 form-group">
               <label class="labeltext labelpadding">Quick Start Programs</label><br>
               <div class="slds-form-element">
                  <div id="lstprogramtypes" class="slds-form-element__control">
                  </div>
               </div>
            </div>
            <div class="col-md-9 col-sm-12 col-xs-12 form-group">
            <label class="labeltext labelpadding">Connectors</label><br>
            	<div class="slds-form-element">
                  <div class="slds-form-element__control">
                     <span class="slds-checkbox">
                     <input type="checkbox" name="options" id="grs" value="grs" class="classDisable"/>
                     <label class="slds-checkbox__label checkboxInline" for="grs">
                     <span class="slds-checkbox_faux customfaux"></span>
                     <span class="slds-form-element__label customLabel">GRS (Global Reward Solutions)</span>
                     </label>
                     </span>
                  </div>
               </div>  
              <div class="slds-form-element">
                  <div class="slds-form-element__control">
                     <span class="slds-checkbox">
                     <input type="checkbox" name="options" id="sendgrid" value="sendgrid"  />
                     <label class="slds-checkbox__label checkboxInline" for="sendgrid">
                     <span class="slds-checkbox_faux customfaux"></span>
                     <span class="slds-form-element__label customLabel">SendGrid</span>
                     </label>
                     </span>
                  </div>
               </div>
            </div>
         </div>
         <div class="col-md-12 buttons">
            <div class="col-md-1" ></div>
            <div class="col-md-1 col-md-offset-10" >
               <button id ="nextButton" class="slds-button slds-button_brand buttonBorder">Install</button>           
            </div>
         </div>
	</div>
	<c:if test="${items != null}">
		<script type="text/javascript">
	
			var GitHubDeploy = {
				// Contents of the GitHub repository
				contents: ${items},
	
				// Render GitHub repository contents
				render: function(container) {
						for(fileIdx in container) {
							var repoItem = container[fileIdx];
							if(repoItem.name !="PRM" && repoItem.name !="CIP"){
								$('#lstprogramtypes').append(
										 ' <span class="slds-checkbox">' +
					                     ' <input type="checkbox" name="options" id="'+ repoItem.full_name +'" value="'+ repoItem.full_name +'" /> '+
					                     ' <label class="slds-checkbox__label" for="'+ repoItem.full_name+'"> '+
					                     ' <span class="slds-checkbox_faux customfaux"></span> '+
					                     ' <span class="slds-form-element__label customLabel">'+ (repoItem.description != null ? repoItem.description : repoItem.name) +'</span>'+
					                     ' </label>'+
					                     ' </span> ');
							}
							//CIP has a diferent HTML to check Invoincing. Training and GRS
							if(repoItem.name =="CIP"){
								$('#lstprogramtypes').append(
										 ' <span class="slds-checkbox">' +
					                     ' <input type="checkbox" name="options" id="'+ repoItem.name +'" value="'+ repoItem.name +'" /> '+
					                     ' <label class="slds-checkbox__label" for="'+ repoItem.name+'"> '+
					                     ' <span class="slds-checkbox_faux customfaux"></span> '+
					                     ' <span class="slds-form-element__label customLabel">'+ (repoItem.description != null ? repoItem.description : repoItem.name) +'</span>'+
					                     ' </label>'+
					                     ' </span> ');
							}
						}
					}		
			}
			
			// Render files selected to deploy
			GitHubDeploy.render(GitHubDeploy.contents);
		</script>
	</c:if>
   </body>
</html>