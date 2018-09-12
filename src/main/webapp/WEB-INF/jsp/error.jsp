<%@taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!DOCTYPE html>
<html>
  <jsp:include page="header.jsp"/>
	<body class="bodycolor">
		<div id ="container" class="container">
			<div class="row">
				<div class="col-md-11 col-md-offset-1">
					<div class="login-title">Oops, something went wrong...Please click on the button below.</div>
					<!--  
					 <p><c:out value="${requestScope['javax.servlet.error.message']}"/></p>
					  <c:if test="${requestScope['javax.servlet.error.message'] == 'Authentication Failed: OAuth login invalid or expired access token'}">
		                <p>Be sure your Salesforce organization does not have IP restrictions. Logout and try with another user or organization.</p>
		                <p><a class="btn btn-inverse" href="/logout">Logout</a></p>
		            </c:if>
		            -->
				</div>
				<div class="col-md-8 col-md-offset-4">
					<button class="slds-button slds-button_brand buttonLogin" onclick="errorLogin();return false;">Home</button>
				</div>
			</div>
		</div>
		<img src="resources/img/lightning_blue_background.png" alt="" style =" height: 360px; width: 100%;">
	</body>
	</html>
	
	
