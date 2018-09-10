/* JavaScript Document

	*	25/07/2018
	*	Author: Fielo
*/

//Get inputCheck - Home Page
function getInputCheck() {
    //var selected = [{"type":"linkRepository","name":"CIP"}];
    var selected = [];
    $("input[type=checkbox]:checked").each(function() {
        if ($(this).attr('id') != "registration" && $(this).attr('id') != "salesforceLeads" &&
            $(this).attr('id') != "salesforceOpportunities" && $(this).attr('id') != "salesforceOrders") {
            if ($(this).attr('id') == "checkboxFieloPlataform") {
                selected.push({
                    type: "package",
                    name: $(this).attr('id')
                });
                console.log($(this).attr('id'));
            } else {
                selected.push({
                    type: "linkRepository",
                    name: $(this).attr('id')
                });
            }
        }
    });
    getInfo(selected);
}


// Verification of Input and Redirect to Deploy
function continueRedirect() {
    var selected = [];
    $("input[type=checkbox]:checked").each(function() {
        if ($(this).attr('id') != "registration" && $(this).attr('id') != "salesforceLeads" &&
            $(this).attr('id') != "salesforceOpportunities" && $(this).attr('id') != "salesforceOrders") {
            if ($(this).attr('id') == "checkboxFieloPlataform") {
                selected.push({
                    type: "package",
                    name: $(this).attr('id')
                });
                console.log($(this).attr('id'));
            } else {
                selected.push({
                    type: "linkRepository",
                    name: $(this).attr('id')
                });
            }
        }
    });
    if (selected.length == 0) {
        alert("Please select at least one of the sources.");
        return;
    }
    var continueUrl =
        $('#app').attr('checked') ?
        'deploy' :
        'deploy';

    var deployForm = document.createElement('FORM');
    deployForm.name = 'myForm';
    deployForm.method = 'POST';
    deployForm.action = continueUrl;

    deployInput = document.createElement('INPUT');
    deployInput.enctype = 'text/plain';
    deployInput.type = 'HIDDEN';
    deployInput.name = 'deployInput';
    deployInput.value = JSON.stringify(selected);
    deployForm.appendChild(deployInput);

    document.body.appendChild(deployForm);
    deployForm.submit();
}


//Get Information about the Org - Deploy Page
function getInfo(selected) {
    $.ajax({
        type: 'POST',
        url: window.location.pathname  + "/getinfo",
        data: JSON.stringify(selected),
        success: function(data, textStatus, jqXHR) {
            var obj = JSON.parse(data);
            var userContext = JSON.parse(obj.userContext);
            console.log(obj);
            $('#dropdownInfo').empty();
            var packages = '<li class="slds-dropdown__item">' +
                '<a href="javascript:void(0);" role="menuitem" tabindex="0">' +
                '<span class="slds-truncate infoPackageLabel">Package</span><span class="slds-truncate infoPackageLabel">Version</span>' +
                '</a>' +
                '</li>';
            for (let i = 0; i < obj.deployList.length; i++) {
                packages = packages +
                    '<li class="slds-dropdown__item">' +
                    '<a href="javascript:void(0);" role="menuitem" tabindex="0">' +
                    '<span class="slds-truncate infoPackageDescription">' + obj.deployList[i].name + '</span>' + '<span class="slds-truncate infoPackageDescription">' + obj.deployList[i].version + '</span>' +
                    '</a></li>';

            }

            $('#dropdownInfo').prepend(packages);

            $('#organizationDescription').text(userContext.organizationName);
            $('#userDescription').text(userContext.userName);

        },
        error: function(jqXHR, textStatus, errorThrown) {
            alert('Failed ' + textStatus + errorThrown);
        }
    });
}

//Progress Bar
function frame(elem, maxP) {

    var elemProgressBar = document.getElementById("progressbar");
    var width = elem;
    if (elem <= maxP) {

        if (width >= 100) {
            $('.progressModal').hide();
            $('.completeModal').fadeIn("slow");
        } else {
            document.getElementById("progressbarInfo").innerHTML = elem + '% Complete';
            elemProgressBar.style.width = elem + '%';
        }
    }
}


// Calculate Percentage from number of packages
function calcPercentage(min, max) {
    var percentage = (min * 100) / max
    return percentage;
}

function goBack() {
    window.history.back();
}

function redirectOrg() {
    window.location.href = 'https://developer.salesforce.com/';
}


$(document).ready(function($) {
    // Default settings
    $('.salesforce').hide();
    $('.salesforceCustomer').hide();

    // Close Alert Message
    $("#cancelDeploy").click(function() {
        $("#myModal").hide();
        $('.alertModal').hide();
    });

    // Verification Checkbox Sales Communities
    $('#checkboxSalesCommunities').change(function() {
        //var onclick = "window.location.href='/customize.html'";
        if (this.checked) {
            var returnVal = confirm("Are you sure?");
            if (returnVal) {
                $.ajax({
                    // This URL need to be changed before release
                    type: 'POST',
                    url:  window.location.pathname  + "/checkcommunity",
                    cache: false,
                    success: function(result) {
                        console.log(result);
                        if (result == "true") {
                            $('#checkboxSalesCommunities').prop("checked");
                            $('.salesforce').fadeIn("slow");
                            $('#alertOrg').hide();
                            $("#myBtn").prop("disabled", false);
                        } else {
                            $('#checkboxSalesCommunities').prop('checked', false);
                            $('#alertOrg').fadeIn("slow");
                            $("#myBtn").prop("disabled", true);
                        }
                    }
                });
            } else {
                $(this).prop('checked', false);
                $('.salesforce').fadeOut("slow");
                $('.salesforceCustomer').fadeOut("slow");
                $('input[type=radio][name=licence]').prop('checked', false);
                $("input.checkBoxsalesforceCustomer[type=checkbox]").prop('checked', false);
            }
        } else {
            $('.salesforce').fadeOut("slow");
            $('.salesforceCustomer').fadeOut("slow");
            $('#alertOrg').fadeOut("slow");
            $('input[type=radio][name=licence]').prop('checked', false);
            $("input.checkBoxsalesforceCustomer[type=checkbox]").prop('checked', false);
        }

    });

    // Verification the version of the PLT
    $("#nextButton").click(function() {
        if ($('#checkboxFieloPlataform').prop('checked')) {
            $.ajax({
                type: 'POST',
                url:  window.location.pathname  + "/checkversionplt",
                success: function(result) {
                    console.log(result);
                    if (result == "true") {
                        $("#myModal").show();
                        $('.alertModal').show();
                    } else {
                        continueRedirect();
                    }
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    alert('Failed ' + textStatus + errorThrown);
                }
            });
        } else {
            continueRedirect();
        }
    });

    // Open Info Packages to be installed	
    $("#openInfoPackages").click(function() {

        if ($('#openInfoPackages').hasClass("slds-is-closed")) {
            $('#openInfoPackages').removeClass('slds-is-closed');
            $('#openInfoPackages').addClass('slds-is-open');
        } else {
            $('#openInfoPackages').removeClass('slds-is-open');
            $('#openInfoPackages').addClass('slds-is-closed');
        }
    });


    // Verification Radio Buttom Licence Parther Community
    $('input[type=radio][name=licence]').change(function() {
        if ($('#partnerCommunity').prop('checked')) {
            $('.salesforceCustomer').fadeIn("slow");
        } else {
            $('.salesforceCustomer').fadeOut("slow");
            $("input.checkBoxsalesforceCustomer[type=checkbox]").prop('checked', false);
        }
    });

    // Disable Invoicing, Training, Registration and GRS when CIP is checked
    $('#CIP').change(function() {
        if (this.checked) {
            $(".classDisable").prop('disabled', true);
            $(".classDisable").prop('checked', true);
        } else {
            $(".classDisable").prop('disabled', false);
            $(".classDisable").prop('checked', false);
        }
    });


});