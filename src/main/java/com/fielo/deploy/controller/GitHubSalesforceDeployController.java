package com.fielo.deploy.controller;

import static org.eclipse.egit.github.core.client.IGitHubConstants.SEGMENT_REPOS;

import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLDecoder;
import java.text.SimpleDateFormat;
import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.InputStreamReader;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;

import javax.xml.namespace.QName;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.w3c.dom.Attr;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.net.ssl.HttpsURLConnection;

import org.codehaus.jackson.annotate.JsonIgnore;
import org.codehaus.jackson.map.ObjectMapper;
import org.eclipse.egit.github.core.IRepositoryIdProvider;
import org.eclipse.egit.github.core.RepositoryContents;
import org.eclipse.egit.github.core.RepositoryId;
import org.eclipse.egit.github.core.client.RequestException;
import org.eclipse.egit.github.core.client.GitHubClient;
import org.eclipse.egit.github.core.client.GitHubRequest;
import org.eclipse.egit.github.core.client.GitHubResponse;
import org.eclipse.egit.github.core.service.ContentsService;
import org.eclipse.egit.github.core.service.RepositoryService;
import org.json.*;
import org.json.simple.parser.JSONParser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.fielo.deploy.utils.GithubUtil;
import com.force.sdk.connector.ForceServiceConnector;
import com.force.sdk.oauth.context.ForceSecurityContextHolder;
import com.force.sdk.oauth.context.SecurityContext;
import com.force.sdk.oauth.exception.ForceOAuthSessionExpirationException;
import com.sforce.soap.metadata.AsyncResult;
import com.sforce.soap.metadata.CodeCoverageWarning;
import com.sforce.soap.metadata.DeployMessage;
import com.sforce.soap.metadata.DeployOptions;
import com.sforce.soap.metadata.DeployResult;
import com.sforce.soap.metadata.DescribeMetadataObject;
import com.sforce.soap.metadata.DescribeMetadataResult;
import com.sforce.soap.metadata.FileProperties;
import com.sforce.soap.metadata.ListMetadataQuery;
import com.sforce.soap.metadata.MetadataConnection;
import com.sforce.soap.metadata.Package;
import com.sforce.soap.metadata.PackageTypeMembers;
import com.sforce.soap.metadata.RunTestFailure;
import com.sforce.soap.metadata.RunTestsResult;
import com.sforce.ws.ConnectionException;
import com.sforce.ws.bind.TypeMapper;
import com.sforce.ws.parser.XmlOutputStream;

@Controller
@RequestMapping("/deploy")
public class GitHubSalesforceDeployController {

	@Autowired
	ServletContext context;

	HttpServletRequest servletRequest;
	ForceServiceConnector forceConnector;

	private static final String ZIP_FILE = "packages" + File.separator;
	private static int MajorVersion = 0;
	private static int MinorVersion = 0;
	private static int PatchVersion = 0;

	@RequestMapping(method = RequestMethod.GET, value = "/logoutgh")
	public String logoutgh(HttpSession session, @RequestParam(required = false) final String retUrl) {
		session.removeAttribute(GithubUtil.GITHUB_TOKEN);
		return retUrl != null ? "redirect:" + retUrl : "redirect:/index.jsp";
	}

	@RequestMapping(method = RequestMethod.GET, value = "/authorizegh")
	public String authorize(@RequestParam final String code, @RequestParam final String state, HttpSession session)
			throws Exception {
		URL url = new URL("https://github.com/login/oauth/access_token");
		HttpsURLConnection connection = (HttpsURLConnection) url.openConnection();
		connection.setRequestMethod("POST");
		connection.setRequestProperty("Accept", "application/json");
		String urlParameters = "client_id=" + System.getenv(GithubUtil.GITHUB_CLIENT_ID) + "&client_secret="
				+ System.getenv(GithubUtil.GITHUB_CLIENT_SECRET) + "&code=" + code;
		// Send post request
		connection.setDoOutput(true);
		DataOutputStream connectionOutputStream = new DataOutputStream(connection.getOutputStream());
		connectionOutputStream.writeBytes(urlParameters);
		connectionOutputStream.flush();
		connectionOutputStream.close();

		// Read response
		BufferedReader inputReader = new BufferedReader(new InputStreamReader(connection.getInputStream()));
		String inputLine;
		StringBuffer gitHubResponse = new StringBuffer();
		while ((inputLine = inputReader.readLine()) != null)
			gitHubResponse.append(inputLine);
		inputReader.close();

		ObjectMapper mapper = new ObjectMapper();
		TokenResult tokenResult = (TokenResult) mapper.readValue(gitHubResponse.toString(), TokenResult.class);
		session.setAttribute(GithubUtil.GITHUB_TOKEN, tokenResult.access_token);
		String redirectUrl = state;
		return "redirect:" + redirectUrl;
	}

	@RequestMapping(method = RequestMethod.GET, value = "/{owner}/{repo}")
	public String confirm(HttpServletRequest request, @PathVariable("owner") String repoOwner,
			@PathVariable("repo") String repoName, @RequestParam(defaultValue = "master", required = false) String ref,
			HttpSession session, Map<String, Object> map) throws Exception {
		try {
			map.put("repo", null);
			map.put("githubcontents", null);
			String accessToken = (String) session.getAttribute(GithubUtil.GITHUB_TOKEN);
			// Repository name
			RepositoryId repoId = RepositoryId.create(repoOwner, repoName);
			map.put("repositoryName", repoId.generateId());
			map.put("ref", ref);

			// Display user info
			ForceServiceConnector forceConnector = new ForceServiceConnector(
					ForceServiceConnector.getThreadLocalConnectorConfig());

			map.put("userContext", forceConnector.getConnection().getUserInfo());

			// Display repo info
			GitHubClient client;
			if (accessToken == null) {
				client = new GitHubClientOAuthServer(System.getenv(GithubUtil.GITHUB_CLIENT_ID),
						System.getenv(GithubUtil.GITHUB_CLIENT_SECRET));
			} else {
				client = new GitHubClient();
				client.setOAuth2Token(accessToken);
				map.put("githuburl", "https://github.com/settings/connections/applications/"
						+ System.getenv(GithubUtil.GITHUB_CLIENT_ID));
			}

			RepositoryService service = new RepositoryService(client);
			try {
				map.put("repo", service.getRepository(repoId));
			} catch (Exception e) {
				if (accessToken == null) {
					StringBuffer requestURL = request.getRequestURL();
					String queryString = request.getQueryString();
					String redirectUrl = queryString == null ? requestURL.toString()
							: requestURL.append('?').append(queryString).toString();
					return "redirect:" + "https://github.com/login/oauth/authorize?client_id="
							+ System.getenv(GithubUtil.GITHUB_CLIENT_ID) + "&scope=repo&state=" + redirectUrl;
				} else {
					map.put("error", "Failed to retrive GitHub repository details : " + e.toString());
				}
			}

			// Prepare Salesforce metadata for repository scan
			RepositoryScanResult repositoryScanResult = new RepositoryScanResult();
			RepositoryItem repositoryContainer = new RepositoryItem();
			repositoryContainer.repositoryItems = new ArrayList<RepositoryItem>();
			repositoryScanResult.metadataDescribeBySuffix = new HashMap<String, DescribeMetadataObject>();
			repositoryScanResult.metadataDescribeByFolder = new HashMap<String, DescribeMetadataObject>();
			DescribeMetadataResult metadataDescribeResult = forceConnector.getMetadataConnection()
					.describeMetadata(36.0); // TODO: Make version configurable / auto
			for (DescribeMetadataObject describeObject : metadataDescribeResult.getMetadataObjects()) {
				if (describeObject.getSuffix() == null) {
					repositoryScanResult.metadataDescribeByFolder.put(describeObject.getDirectoryName(),
							describeObject);
				} else {
					repositoryScanResult.metadataDescribeBySuffix.put(describeObject.getSuffix(), describeObject);
					if (describeObject.getMetaFile())
						repositoryScanResult.metadataDescribeBySuffix.put(describeObject.getSuffix() + "-meta.xml",
								describeObject);
				}
			}

			// Retrieve repository contents applicable for deploy
			ContentsServiceEx contentService = new ContentsServiceEx(client);

			try {
				scanRepository(contentService, repoId, ref, contentService.getContents(repoId, null, ref),
						repositoryContainer, repositoryScanResult);

				// Determine correct root to emit to the page
				RepositoryItem githubcontents = null;
				if (repositoryScanResult.pacakgeRepoDirectory != null) {
					githubcontents = repositoryScanResult.pacakgeRepoDirectory;
				} else if (repositoryContainer.repositoryItems.size() > 0) {
					githubcontents = repositoryContainer;
				}

				// Serialize JSON to page
				if (githubcontents != null) {
					githubcontents.ref = ref; // Remember branch/tag/commit reference
					map.put("githubcontents", new ObjectMapper().writeValueAsString(githubcontents));
				} else {
					map.put("error", "No Salesforce files found in repository.");
				}
			} catch (RequestException e) {
				if (e.getStatus() == 404)
					map.put("error", "Could not find the repository '" + repoName
							+ "'. Ensure it is spelt correctly and that it is owned by '" + repoOwner + "'");
				else
					map.put("error", "Failed to scan the repository '" + repoName
							+ "'. Callout to Github failed with status code " + e.getStatus());
			}
		} catch (ForceOAuthSessionExpirationException e) {
			return "redirect:/logout";
		} catch (Exception e) {
			// Handle error
			map.put("error", "Unhandled Exception : " + e.toString());
			e.printStackTrace();
		}
		return "deploy";
	}

	@RequestMapping(method = { RequestMethod.POST }, value = "")
	public String home(@RequestBody String selectionList, HttpServletRequest request, HttpSession session,
			Map<String, Object> map) throws Exception {
		selectionList = URLDecoder.decode(selectionList, "UTF-8");
		selectionList = selectionList.substring(selectionList.indexOf('['));
		org.json.simple.JSONArray selection = (org.json.simple.JSONArray) (new JSONParser()).parse(selectionList);
		org.json.simple.JSONArray deployList = GithubUtil.getDeployList(selection);

		updateStaticVariables(deployList);
		servletRequest = request;

		// Display user info
		forceConnector = new ForceServiceConnector(ForceServiceConnector.getThreadLocalConnectorConfig());
		try {
			map.put("userContext", forceConnector.getConnection().getUserInfo());
			map.put("githubcontents", "{}");
		} catch (Exception e) {
			return "error";
		}

		/*
		 * String reposList = ""; File file = new File(context.getRealPath("/") +
		 * "deploys.json"); if(!file.exists()) { throw new
		 * Exception("Deployment list not found."); } else { //get file JSONParser
		 * parser = new JSONParser(); try{ reposList = parser.parse(new
		 * FileReader(file.getAbsolutePath())).toString().replace("\\","");
		 * }catch(java.io.FileNotFoundException e){ System.out.println(e.getMessage());
		 * } }
		 */
		System.out.println(selectionList);

		map.put("deployList", deployList.toString());

		return "deploy";
	}

	// @ResponseBody
	// @RequestMapping(method = RequestMethod.POST, value = "/{owner}/{repo}")
	/*
	 * public String deploy(
	 * 
	 * @PathVariable("owner") String repoOwner,
	 * 
	 * @PathVariable("repo") String repoName,
	 * 
	 * @RequestBody String repoContentsJson, HttpServletResponse response,
	 * Map<String,Object> map, HttpSession session) throws Exception { DeployType
	 * deployType = DeployType.PACKAGE; // TODO: Parameterise String resp;
	 * 
	 * if (deployType == DeployType.PACKAGE) { return deployPackage("deployPLT"); }
	 * else return deployRepository(repoOwner, repoName, repoContentsJson, response,
	 * map, session); }
	 */

	public Map<String, Object> getGitHubData(String repoOwner, String repoName, String ref, HttpSession session)
			throws Exception {
		Map<String, Object> map = new HashMap<String, Object>();
		try {
			map.put("repo", null);
			map.put("githubcontents", null);
			String accessToken = (String) session.getAttribute(GithubUtil.GITHUB_TOKEN);
			// Repository name
			RepositoryId repoId = RepositoryId.create(repoOwner, repoName);
			map.put("repositoryName", repoId.generateId());
			map.put("ref", ref);

			// Display repo info
			GitHubClient client;
			if (accessToken == null) {
				client = new GitHubClientOAuthServer(System.getenv(GithubUtil.GITHUB_CLIENT_ID),
						System.getenv(GithubUtil.GITHUB_CLIENT_SECRET));
			} else {
				client = new GitHubClient();
				client.setOAuth2Token(accessToken);
				map.put("githuburl", "https://github.com/settings/connections/applications/"
						+ System.getenv(GithubUtil.GITHUB_CLIENT_ID));
			}

			RepositoryService service = new RepositoryService(client);
			try {
				map.put("repo", service.getRepository(repoId));
			} catch (Exception e) {
				if (accessToken == null) {
					StringBuffer requestURL = servletRequest.getRequestURL();
					String queryString = servletRequest.getQueryString();
					String redirectUrl = queryString == null ? requestURL.toString()
							: requestURL.append('?').append(queryString).toString();
					// return "redirect:" + "https://github.com/login/oauth/authorize?client_id=" +
					// System.getenv(GITHUB_CLIENT_ID) + "&scope=repo&state=" + redirectUrl;
					map.put("redirect", "https://github.com/login/oauth/authorize?client_id="
							+ System.getenv(GithubUtil.GITHUB_CLIENT_ID) + "&scope=repo&state=" + redirectUrl);
				} else {
					map.put("error", "Failed to retrieve GitHub repository details : " + e.toString());
				}
			}

			// Prepare Salesforce metadata for repository scan
			RepositoryScanResult repositoryScanResult = new RepositoryScanResult();
			RepositoryItem repositoryContainer = new RepositoryItem();
			repositoryContainer.repositoryItems = new ArrayList<RepositoryItem>();
			repositoryScanResult.metadataDescribeBySuffix = new HashMap<String, DescribeMetadataObject>();
			repositoryScanResult.metadataDescribeByFolder = new HashMap<String, DescribeMetadataObject>();
			DescribeMetadataResult metadataDescribeResult = forceConnector.getMetadataConnection()
					.describeMetadata(36.0); // TODO: Make version configurable / auto
			for (DescribeMetadataObject describeObject : metadataDescribeResult.getMetadataObjects()) {
				if (describeObject.getSuffix() == null) {
					repositoryScanResult.metadataDescribeByFolder.put(describeObject.getDirectoryName(),
							describeObject);
				} else {
					repositoryScanResult.metadataDescribeBySuffix.put(describeObject.getSuffix(), describeObject);
					if (describeObject.getMetaFile())
						repositoryScanResult.metadataDescribeBySuffix.put(describeObject.getSuffix() + "-meta.xml",
								describeObject);
				}
			}

			// Retrieve repository contents applicable for deploy
			ContentsServiceEx contentService = new ContentsServiceEx(client);

			try {
				scanRepository(contentService, repoId, ref, contentService.getContents(repoId, null, ref),
						repositoryContainer, repositoryScanResult);

				// Determine correct root to emit to the page
				RepositoryItem githubcontents = null;
				if (repositoryScanResult.pacakgeRepoDirectory != null) {
					githubcontents = repositoryScanResult.pacakgeRepoDirectory;
				} else if (repositoryContainer.repositoryItems.size() > 0) {
					githubcontents = repositoryContainer;
				}

				// Serialize JSON to page
				if (githubcontents != null) {
					githubcontents.ref = ref; // Remember branch/tag/commit reference
					map.put("githubcontents", new ObjectMapper().writeValueAsString(githubcontents));
				} else {
					map.put("error", "No Salesforce files found in repository.");
				}
			} catch (RequestException e) {
				if (e.getStatus() == 404)
					map.put("error", "Could not find the repository '" + repoName
							+ "'. Ensure it is spelt correctly and that it is owned by '" + repoOwner + "'");
				else
					map.put("error", "Failed to scan the repository '" + repoName
							+ "'. Callout to Github failed with status code " + e.getStatus());
			}
		} catch (ForceOAuthSessionExpirationException e) {
			// return "redirect:/logout";
			// Handle error
			map.put("error", "Session Expiration Exception : " + e.toString());
			e.printStackTrace();

		} catch (Exception e) {
			// Handle error
			map.put("error", "Unhandled Exception : " + e.toString());
			e.printStackTrace();
		}
		return map;
	}

	@ResponseBody
	@RequestMapping(method = RequestMethod.POST, value = "/{owner}/{repo}/{ref:.+}")
	public String deployRepository(@PathVariable("owner") String repoOwner, @PathVariable("repo") String repoName,
			@PathVariable("ref") String ref, @RequestBody String repoContentsJson, HttpServletResponse response,
			Map<String, Object> map, HttpSession session) throws Exception {
		String accessToken = (String) session.getAttribute(GithubUtil.GITHUB_TOKEN);

		GitHubClient client;

		if (accessToken == null) {
			// Connect via oAuth client and secret to get greater request limits
			client = new GitHubClientOAuthServer(System.getenv(GithubUtil.GITHUB_CLIENT_ID),
					System.getenv(GithubUtil.GITHUB_CLIENT_SECRET));
		} else {
			// Connect with access token to deploy private repositories
			client = new GitHubClient();
			client.setOAuth2Token(accessToken);
		}

		// Get map with repo information
		Map<String, Object> repoMap = getGitHubData(repoOwner, repoName, ref, session);

		// Repository files to deploy
		ObjectMapper mapper = new ObjectMapper();
		RepositoryItem repositoryContainer = (RepositoryItem) mapper.readValue(repoMap.get("githubcontents").toString(),
				RepositoryItem.class);

		// Performing a package deployment from a package manifest in the repository?
		String repoPackagePath = null;
		RepositoryItem firstFile = repositoryContainer.repositoryItems.get(0);
		if (firstFile.repositoryItem.getName().equals("package.xml"))
			repoPackagePath = firstFile.repositoryItem.getPath().substring(0,
					firstFile.repositoryItem.getPath().length() - (firstFile.repositoryItem.getName().length()));

		// Calculate a package manifest?
		String packageManifestXml = null;
		Map<String, RepositoryItem> filesToDeploy = new HashMap<String, RepositoryItem>();
		Map<String, List<String>> typeMembersByType = new HashMap<String, List<String>>();
		if (repoPackagePath == null) {
			// Construct package manifest and files to deploy map by path
			Package packageManifest = new Package();
			packageManifest.setVersion("36.0"); // TODO: Make version configurable / auto
			List<PackageTypeMembers> packageTypeMembersList = new ArrayList<PackageTypeMembers>();
			scanFilesToDeploy(filesToDeploy, typeMembersByType, repositoryContainer);
			for (String metadataType : typeMembersByType.keySet()) {
				PackageTypeMembers packageTypeMembers = new PackageTypeMembers();
				packageTypeMembers.setName(metadataType);
				packageTypeMembers.setMembers((String[]) typeMembersByType.get(metadataType).toArray(new String[0]));
				packageTypeMembersList.add(packageTypeMembers);
			}
			packageManifest.setTypes((PackageTypeMembers[]) packageTypeMembersList.toArray(new PackageTypeMembers[0]));
			// Serialise it (better way to do this?)
			TypeMapper typeMapper = new TypeMapper();
			ByteArrayOutputStream packageBaos = new ByteArrayOutputStream();
			QName packageQName = new QName("http://soap.sforce.com/2006/04/metadata", "Package");
			XmlOutputStream xmlOutputStream = new XmlOutputStream(packageBaos, true);
			xmlOutputStream.setPrefix("", "http://soap.sforce.com/2006/04/metadata");
			xmlOutputStream.setPrefix("xsi", "http://www.w3.org/2001/XMLSchema-instance");
			packageManifest.write(packageQName, xmlOutputStream, typeMapper);
			xmlOutputStream.close();
			packageManifestXml = new String(packageBaos.toByteArray());
		}

		// Download the Repository as an archive zip
		RepositoryId repoId = RepositoryId.create(repoOwner, repoName);
		ContentsServiceEx contentService = new ContentsServiceEx(client);
		ZipInputStream zipIS;
		try {
			zipIS = contentService.getArchiveAsZip(repoId, repositoryContainer.ref);
		} catch (RequestException e) {
			session.removeAttribute(GithubUtil.GITHUB_TOKEN);
			response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "GitHub Token Invalid");
			return "";
		}

		// Dynamically generated package manifest?
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		ZipOutputStream zipOS = new ZipOutputStream(baos);
		if (packageManifestXml != null) {
			ZipEntry metadataZipEntry = new ZipEntry("package.xml");
			zipOS.putNextEntry(metadataZipEntry);
			zipOS.write(packageManifestXml.getBytes());
			zipOS.closeEntry();
		}
		// Read the zip entries, output to the metadata deploy zip files selected
		while (true) {
			ZipEntry zipEntry = zipIS.getNextEntry();
			if (zipEntry == null)
				break;
			// Determine the repository relative path (zip file contains an archive folder
			// in root)
			String zipPath = zipEntry.getName();
			String repoPath = zipPath.substring(zipPath.indexOf("/") + 1);
			// Found a repository file to deploy?
			if (filesToDeploy.containsKey(repoPath)) {
				// Create metadata file (in correct folder for its type)
				RepositoryItem repoItem = filesToDeploy.get(repoPath);
				String zipName = repoItem.metadataFolder + "/";
				if (repoItem.metadataInFolder) {
					String[] folders = repoItem.repositoryItem.getPath().split("/");
					String folderName = folders[folders.length - 2];
					zipName += folderName + "/";
				}
				zipName += repoItem.repositoryItem.getName();
				ZipEntry metadataZipEntry = new ZipEntry(zipName);
				zipOS.putNextEntry(metadataZipEntry);
				// Copy bytes over from Github archive input stream to Metadata zip output
				// stream
				byte[] buffer = new byte[1024];
				int length = 0;
				while ((length = zipIS.read(buffer)) > 0)
					zipOS.write(buffer, 0, length);
				zipOS.closeEntry();
				// Missing metadata file for Apex classes?
				if (repoItem.metadataType.equals("ApexClass") && !filesToDeploy.containsKey(repoPath + "-meta.xml")) {
					StringBuilder sb = new StringBuilder();
					sb.append("<ApexClass xmlns=\"http://soap.sforce.com/2006/04/metadata\">");
					sb.append("<apiVersion>43.0</apiVersion>"); // TODO: Make version configurable / auto
					sb.append("<status>Active</status>");
					sb.append("</ApexClass>");
					ZipEntry missingMetadataZipEntry = new ZipEntry(
							repoItem.metadataFolder + "/" + repoItem.repositoryItem.getName() + "-meta.xml");
					zipOS.putNextEntry(missingMetadataZipEntry);
					zipOS.write(sb.toString().getBytes());
					zipOS.closeEntry();
				}
			}
			// Found a package directory to deploy?
			else if (repoPackagePath != null && repoPath.equals(repoPackagePath)) {
				while (true) {
					// More package files to zip or dropped out of the package folder?
					zipEntry = zipIS.getNextEntry();
					if (zipEntry == null || !zipEntry.getName().startsWith(zipPath))
						break;
					// Generate the Metadata zip entry name
					String metadataZipEntryName = zipEntry.getName().substring(zipPath.length());
					ZipEntry metadataZipEntry = new ZipEntry(metadataZipEntryName);
					zipOS.putNextEntry(metadataZipEntry);
					// Copy bytes over from Github archive input stream to Metadata zip output
					// stream
					byte[] buffer = new byte[1024];
					int length = 0;
					while ((length = zipIS.read(buffer)) > 0)
						zipOS.write(buffer, 0, length);
					zipOS.closeEntry();
				}
				break;
			}
		}
		zipOS.close();

		// Connect to Salesforce Metadata API
		ForceServiceConnector connector = new ForceServiceConnector(
				ForceServiceConnector.getThreadLocalConnectorConfig());

		MetadataConnection metadataConnection = connector.getMetadataConnection();

		// Deploy to Salesforce
		DeployOptions deployOptions = new DeployOptions();
		deployOptions.setSinglePackage(true);
		deployOptions.setPerformRetrieve(false);
		deployOptions.setRollbackOnError(true);
		AsyncResult asyncResult = metadataConnection.deploy(baos.toByteArray(), deployOptions);

		// Given the client the AysncResult to poll for the result of the deploy
		ObjectMapper objectMapper = new ObjectMapper();
		objectMapper.getSerializationConfig().addMixInAnnotations(AsyncResult.class, AsyncResultMixIn.class);
		return objectMapper.writeValueAsString(asyncResult);
	}

	@ResponseBody
	@RequestMapping(method = RequestMethod.POST, value = "/{package}/{version:.+}")
	public String deployPackage(@PathVariable("package") String packageName,
			@PathVariable("version") String packageVersion, HttpServletResponse response) throws Exception {
		// Connect to Salesforce Metadata API
		ForceServiceConnector connector = new ForceServiceConnector(
				ForceServiceConnector.getThreadLocalConnectorConfig());

		MetadataConnection metadataConnection = connector.getMetadataConnection();

		String packagePath = context.getRealPath("/") + ZIP_FILE;
		System.out.println("Zip file path: " + packagePath);

		if (!writeXmlFile(packagePath, packageName, packageVersion)) {
			throw new Exception("Cannot create the XML file to deploy. Tried to create " + packagePath
					+ "installedPackages" + File.separator + packageName + ".installedPackage");
		}
		if (!writeZipFile(packagePath, packageName)) {
			throw new Exception(
					"Cannot create the ZIP file to deploy. Tried to create " + packagePath + packageName + ".zip");
		}

		// Deploy to Salesforce
		byte zipBytes[] = readZipFile(packagePath, packageName);
		System.out.println("zipBytes: " + zipBytes.length);
		DeployOptions deployOptions = new DeployOptions();
		deployOptions.setPerformRetrieve(false);
		deployOptions.setRollbackOnError(true);
		System.out.println("Starting to deploy " + packagePath + packageName + ".zip");
		AsyncResult asyncResult = metadataConnection.deploy(zipBytes, deployOptions);
		System.out.println("Finished deploying " + packagePath + packageName + ".zip");

		// Given the client the AysncResult to poll for the result of the deploy
		ObjectMapper objectMapper = new ObjectMapper();
		objectMapper.getSerializationConfig().addMixInAnnotations(AsyncResult.class, AsyncResultMixIn.class);
		return objectMapper.writeValueAsString(asyncResult);
	}

	/**
	 * Create the XML file for package deploying.
	 * 
	 * @return Boolean
	 * @throws Exception - if cannot generate the XML file
	 */
	private Boolean writeXmlFile(String packagePath, String packageName, String packageVersion) throws Exception {
		Boolean result = false;

		try {
			/*
			 * String lineSeparator = System.getProperty("line.separator");
			 * System.out.println("Line separator length before: " +
			 * System.getProperty("line.separator").length());
			 * System.setProperty("line.separator", "\r\n");
			 * System.out.println("Line separator length during: " +
			 * System.getProperty("line.separator").length());
			 */
			DocumentBuilderFactory docFactory = DocumentBuilderFactory.newInstance();
			DocumentBuilder docBuilder = docFactory.newDocumentBuilder();

			// Root element
			Document doc = docBuilder.newDocument();
			// doc.setXmlStandalone(true);
			Element rootElement = doc.createElement("InstalledPackage");
			doc.appendChild(rootElement);

			// Set attribute to root element
			Attr attr = doc.createAttribute("xmlns");
			attr.setValue("http://soap.sforce.com/2006/04/metadata");
			rootElement.setAttributeNode(attr);

			// Version number
			Element versionNumber = doc.createElement("versionNumber");
			versionNumber.appendChild(doc.createTextNode(packageVersion));
			rootElement.appendChild(versionNumber);

			// write the content into xml file
			TransformerFactory transformerFactory = TransformerFactory.newInstance();
			Transformer transformer = transformerFactory.newTransformer();
			transformer.setOutputProperty(OutputKeys.ENCODING, "UTF-8");
			transformer.setOutputProperty(OutputKeys.INDENT, "yes");
			transformer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "4");

			DOMSource source = new DOMSource(doc);
			StreamResult file = new StreamResult(
					new File(packagePath + "installedPackages" + File.separator + packageName + ".installedPackage"));

			transformer.transform(source, file);
			/*
			 * System.setProperty("line.separator", lineSeparator);
			 * System.out.println("Line separator length after: " +
			 * System.getProperty("line.separator").length());
			 */
			// System.out.println("File saved!");
			result = true;

		} catch (ParserConfigurationException pce) {
			pce.printStackTrace();
		} catch (TransformerException tfe) {
			tfe.printStackTrace();
		}
		return result;
	}

	/**
	 * Create the zip file for package deploy.
	 * 
	 * @return byte[]
	 * @throws Exception - if cannot create the zip file to deploy
	 */
	private boolean writeZipFile(String packagePath, String packageName) throws Exception {

		boolean result = false;
		byte[] buffer = new byte[1024];
		int len;

		// Input files /
		String[] fileNames = new String[] { "package.xml",
				"installedPackages" + File.separator + packageName + ".installedPackage" };

		// Output file
		ZipOutputStream out = new ZipOutputStream(new FileOutputStream(packagePath + packageName + ".zip"));

		for (String fileName : fileNames) {
			FileInputStream in = new FileInputStream(packagePath + fileName);
			out.putNextEntry(new ZipEntry(packageName + "/" + fileName.replace('\\', '/')));
			while ((len = in.read(buffer)) > 0) {
				out.write(buffer, 0, len);
			}
			out.closeEntry();
			in.close();
			System.out.println("Added: " + packagePath + fileName);
		}
		out.close();
		System.out.println("Zipped: " + packagePath + packageName + ".zip");
		return true;
	}

	/**
	 * Read the zip file contents into a byte array.
	 * 
	 * @return byte[]
	 * @throws Exception - if cannot find the zip file to deploy
	 */
	private byte[] readZipFile(String packagePath, String packageName) throws Exception {
		// We assume here that you have a deploy.zip file.
		// See the retrieve sample for how to retrieve a zip file.
		File deployZip = new File(packagePath + packageName + ".zip");
		if (!deployZip.exists() || !deployZip.isFile())
			throw new Exception("Cannot find the zip file to deploy. Looking for " + deployZip.getAbsolutePath());

		FileInputStream fos = new FileInputStream(deployZip);
		ByteArrayOutputStream bos = new ByteArrayOutputStream();
		int readbyte = -1;
		while ((readbyte = fos.read()) != -1) {
			bos.write(readbyte);
		}
		fos.close();
		bos.close();
		return bos.toByteArray();
	}

	@ResponseBody
	@RequestMapping(method = RequestMethod.GET, value = "/checkstatus/{asyncId}")
	// @RequestMapping(method = RequestMethod.GET, value =
	// "/{owner}/{repo}/checkstatus/{asyncId}")
	public String checkStatus(@PathVariable("asyncId") String asyncId) throws Exception {
		// Connect to Metadata API, check async status and return to client
		ForceServiceConnector connector = new ForceServiceConnector(
				ForceServiceConnector.getThreadLocalConnectorConfig());
		MetadataConnection metadataConnection = connector.getMetadataConnection();
		AsyncResult asyncResult = metadataConnection.checkStatus(new String[] { asyncId })[0];
		ObjectMapper objectMapper = new ObjectMapper();
		objectMapper.getSerializationConfig().addMixInAnnotations(AsyncResult.class, AsyncResultMixIn.class);
		return objectMapper.writeValueAsString(asyncResult);
	}

	@ResponseBody
	@RequestMapping(method = RequestMethod.GET, value = "/checkdeploy/{asyncId}")
	// @RequestMapping(method = RequestMethod.GET, value =
	// "/{owner}/{repo}/checkdeploy/{asyncId}")
	public String checkDeploy(@PathVariable("asyncId") String asyncId) throws Exception {
		// Connect to Metadata API, check async status and return to client
		ForceServiceConnector connector = new ForceServiceConnector(
				ForceServiceConnector.getThreadLocalConnectorConfig());
		MetadataConnection metadataConnection = connector.getMetadataConnection();
		DeployResult deployResult = metadataConnection.checkDeployStatus(asyncId);
		ObjectMapper objectMapper = new ObjectMapper();
		return objectMapper.writeValueAsString(printErrors(deployResult));
	}

	@ResponseBody
	@RequestMapping(method = { RequestMethod.POST }, value = "/checkversionplt")
	public String checkVersionPLT(HttpServletRequest request, HttpSession session, @RequestBody String repoContentsJson)
			throws Exception

	{
		SecurityContext sc = ForceSecurityContextHolder.get();
		String output;
		StringBuilder sb = new StringBuilder();
		String flag = "false";

		// This URL need 'tooling' to be able to execute this query
		String stringURL = sc.getEndPointHost()
				+ "/services/data/v43.0/tooling/query/?q=SELECT+SubscriberPackageId,+SubscriberPackage.Name,+SubscriberPackageVersion.Name,+SubscriberPackageVersion.MajorVersion,+SubscriberPackageVersion.MinorVersion,+SubscriberPackageVersion.PatchVersion+FROM+InstalledSubscriberPackage+where+SubscriberPackageId='03350000000H3lkAAC'";
		try {

			URL url = new URL(stringURL);
			HttpURLConnection conn = (HttpURLConnection) url.openConnection();

			conn.setRequestMethod("GET");
			conn.setRequestProperty("Authorization", "Bearer " + sc.getSessionId());
			conn.setRequestProperty("Accept", "application/json");
			if (conn.getResponseCode() != 200) {
				throw new RuntimeException("Failed : HTTP error code : " + conn.getResponseCode());
			}

			// Get all Information from REST call
			BufferedReader br = new BufferedReader(new InputStreamReader((conn.getInputStream())));
			while ((output = br.readLine()) != null) {
				sb.append(output);
			}

			// Cast Info into a JSONObject
			JSONObject json = new JSONObject(sb.toString());
			JSONArray jsonArray = json.getJSONArray("records");
			Iterator<Object> iterator = jsonArray.iterator();
			while (iterator.hasNext()) {
				JSONObject jsonObject = (JSONObject) iterator.next();
				for (String key : jsonObject.keySet()) {
					if (key.equals("SubscriberPackageVersion")) {
						JSONObject jsonItem = (JSONObject) jsonObject.get(key);
						int itemMajorVersion = Integer.parseInt(jsonItem.get("MajorVersion").toString());
						int itemMinorVersion = Integer.parseInt(jsonItem.get("MinorVersion").toString());
						int itemPatchVersion = Integer.parseInt(jsonItem.get("PatchVersion").toString());
						if (itemMajorVersion < MajorVersion || itemMinorVersion < MinorVersion
								|| itemPatchVersion < PatchVersion) {
							flag = "true";
						}
					}
				}
			}
			conn.disconnect();

		} catch (MalformedURLException e) {

			e.printStackTrace();

		} catch (IOException e) {

			e.printStackTrace();

		}

		return flag;
	}

	/**
	 * Used with the Jackson JSON library to exclude conflicting getters when
	 * serialising AsyncResult (see
	 * http://wiki.fasterxml.com/JacksonMixInAnnotations)
	 */
	public abstract class AsyncResultMixIn {
		@JsonIgnore
		abstract boolean isCheckOnly();

		@JsonIgnore
		abstract boolean isDone();
	}

	/**
	 * Container to reflect repository structure
	 */
	public static class RepositoryItem {
		public String ref;
		public RepositoryContents repositoryItem;
		public ArrayList<RepositoryItem> repositoryItems;
		public String metadataFolder;
		public String metadataType;
		public Boolean metadataFile;
		public Boolean metadataInFolder;
		public String metadataSuffix;
	}

	public static class RepositoryScanResult {
		public String packageRepoPath;
		public RepositoryItem pacakgeRepoDirectory;
		public HashMap<String, DescribeMetadataObject> metadataDescribeBySuffix;
		public HashMap<String, DescribeMetadataObject> metadataDescribeByFolder;
	}

	public static class TokenResult {
		public String access_token;
		public String scope;
		public String token_type;
		public String error;
		public String error_description;
		public String error_uri;
	}

	/**
	 * Extended GitHub Content Service, adds ability to retrieve the repo archive
	 */
	public static class ContentsServiceEx extends ContentsService {
		public ContentsServiceEx(GitHubClient client) {
			super(client);
		}

		public ZipInputStream getArchiveAsZip(IRepositoryIdProvider repository, String ref) throws Exception {
			// https://developer.github.com/v3/repos/contents/#get-archive-link
			String id = getId(repository);
			StringBuilder uri = new StringBuilder(SEGMENT_REPOS);
			uri.append('/').append(id);
			uri.append('/').append("zipball");
			if (ref != null) {
				uri.append('/').append(ref);
			}
			GitHubRequest request = createRequest();
			request.setUri(uri);
			return new ZipInputStream(getClient().getStream(request));
		}
	}

	/**
	 * Adds support for OAuth Client ID and Client Secret authentication (server to
	 * server)
	 *
	 * Note: Only overrides 'get' and 'getStream'
	 */
	public static class GitHubClientOAuthServer extends GitHubClient {
		private String clientId;
		private String clientSecret;

		public GitHubClientOAuthServer(String clientId, String clientSecret) {
			this.clientId = clientId;
			this.clientSecret = clientSecret;
		}

		public InputStream getStream(final GitHubRequest request) throws IOException {
			return super.getStream(applyClientIdAndSecret(request));
		}

		public GitHubResponse get(GitHubRequest request) throws IOException {
			return super.get(applyClientIdAndSecret(request));
		}

		private GitHubRequest applyClientIdAndSecret(GitHubRequest request) {
			Map<String, String> params = request.getParams() != null ? new HashMap<String, String>(request.getParams())
					: new HashMap<String, String>();
			params.put("client_id", clientId);
			params.put("client_secret", clientSecret);
			request.setParams(params);
			return request;
		}
	}

	/**
	 * Discovers the contents of a GitHub repository
	 * 
	 * @param contentService
	 * @param repoId
	 * @param contents
	 * @param repositoryContainer
	 * @throws Exception
	 */
	private static void scanRepository(ContentsService contentService, RepositoryId repoId, String ref,
			List<RepositoryContents> contents, RepositoryItem repositoryContainer,
			RepositoryScanResult repositoryScanResult) throws Exception {
		// Process files first
		for (RepositoryContents repo : contents) {
			// Skip directories for now, see below
			if (repo.getType().equals("dir"))
				continue;
			// Found a Salesforce package manifest?
			if (repo.getName().equals("package.xml")) {
				repositoryScanResult.packageRepoPath = repo.getPath().substring(0,
						repo.getPath().length() - (repo.getName().length()));
				if (repositoryScanResult.packageRepoPath.endsWith("/"))
					repositoryScanResult.packageRepoPath = repositoryScanResult.packageRepoPath.substring(0,
							repositoryScanResult.packageRepoPath.length() - 1);
				RepositoryItem repositoryItem = new RepositoryItem();
				repositoryItem.repositoryItem = repo;
				repositoryContainer.repositoryItems.add(repositoryItem);
				continue;
			}
			// Could this be a Salesforce file?
			int extensionPosition = repo.getName().lastIndexOf(".");
			if (extensionPosition == -1) // File extension?
				continue;
			String fileExtension = repo.getName().substring(extensionPosition + 1);
			String fileNameWithoutExtension = repo.getName().substring(0, extensionPosition);
			// Could this be Salesforce metadata file?
			if (fileExtension.equals("xml")) {
				// Adjust to look for a Salesforce metadata file extension?
				extensionPosition = fileNameWithoutExtension.lastIndexOf(".");
				if (extensionPosition != -1)
					fileExtension = repo.getName().substring(extensionPosition + 1);
			}
			// Is this file extension recognised by Salesforce Metadata API?
			DescribeMetadataObject metadataObject = repositoryScanResult.metadataDescribeBySuffix.get(fileExtension);
			if (metadataObject == null) {
				// Is this a file within a sub-directory of a metadata folder?
				// e.g. src/documents/Eventbrite/Eventbrite_Sync_Logo.png
				String[] folders = repo.getPath().split("/");
				if (folders.length > 3) {
					// Metadata describe for containing folder?
					metadataObject = repositoryScanResult.metadataDescribeByFolder.get(folders[folders.length - 3]);
					if (metadataObject == null)
						continue;
				}
				// Is this a metadata file for a sub-folder within the root of a metadata
				// folder?
				// (such as the XML metadata file for a folder in documents)
				// e.g. src/documents/Eventbrite
				// src/documents/Eventbrite-meta.xml <<<<
				else if (folders.length > 2) {
					// Metadata describe for metadata folder?
					metadataObject = repositoryScanResult.metadataDescribeByFolder.get(folders[folders.length - 2]);
					if (metadataObject == null)
						continue;
					// If package.xml is to be generated for this repo, ensure folders are added to
					// the package items
					// via special value in suffix, see scanFilesToDeploy method
					metadataObject.setSuffix("dir");
				} else
					continue;
			}
			// Add file
			RepositoryItem repositoryItem = new RepositoryItem();
			repositoryItem.repositoryItem = repo;
			repositoryItem.metadataFolder = metadataObject.getDirectoryName();
			repositoryItem.metadataType = metadataObject.getXmlName();
			repositoryItem.metadataFile = metadataObject.getMetaFile();
			repositoryItem.metadataInFolder = metadataObject.getInFolder();
			repositoryItem.metadataSuffix = metadataObject.getSuffix();
			repositoryContainer.repositoryItems.add(repositoryItem);
		}
		// Process directories
		for (RepositoryContents repo : contents) {
			if (repo.getType().equals("dir")) {
				RepositoryItem repositoryItem = new RepositoryItem();
				repositoryItem.repositoryItem = repo;
				repositoryItem.repositoryItems = new ArrayList<RepositoryItem>();
				scanRepository(contentService, repoId, ref,
						contentService.getContents(repoId, repo.getPath().replace(" ", "%20"), ref), repositoryItem,
						repositoryScanResult);
				if (repositoryScanResult.packageRepoPath != null
						&& repo.getPath().equals(repositoryScanResult.packageRepoPath))
					repositoryScanResult.pacakgeRepoDirectory = repositoryItem;
				if (repositoryItem.repositoryItems.size() > 0)
					repositoryContainer.repositoryItems.add(repositoryItem);
			}
		}
	}

	/**
	 * Scans the files the user selected they want to deploy and maps the paths and
	 * metadata types
	 * 
	 * @param filesToDeploy
	 * @param typeMembersByType
	 * @param repositoryContainer
	 */
	private void scanFilesToDeploy(Map<String, RepositoryItem> filesToDeploy,
			Map<String, List<String>> typeMembersByType, RepositoryItem repositoryContainer) {
		for (RepositoryItem repositoryItem : repositoryContainer.repositoryItems) {
			if (repositoryItem.repositoryItem.getType().equals("dir")) {
				// Scan into directory
				scanFilesToDeploy(filesToDeploy, typeMembersByType, repositoryItem);
			} else {
				// Map path to repository item
				filesToDeploy.put(repositoryItem.repositoryItem.getPath(), repositoryItem);
				// Is this repository file a metadata file?
				Boolean isMetadataFile = repositoryItem.repositoryItem.getName().endsWith(".xml");
				Boolean isMetadataFileForFolder = "dir".equals(repositoryItem.metadataSuffix);
				if (isMetadataFile) // Skip meta files
					if (!isMetadataFileForFolder) // As long as its not a metadata file for a folder
						continue;
				// Add item to list by metadata type for package manifiest generation
				List<String> packageTypeMembers = typeMembersByType.get(repositoryItem.metadataType);
				if (packageTypeMembers == null)
					typeMembersByType.put(repositoryItem.metadataType, (packageTypeMembers = new ArrayList<String>()));
				// Determine the component name
				String componentName = repositoryItem.repositoryItem.getName();
				if (componentName.indexOf(".") > 0) // Strip file extension?
					componentName = componentName.substring(0, componentName.indexOf("."));
				if (componentName.indexOf("-meta") > 0) // Strip any -meta suffix (on the end of folder metadata file
														// names)?
					componentName = componentName.substring(0, componentName.indexOf("-meta"));
				// Qualify the component name by its folder?
				if (repositoryItem.metadataInFolder) {
					// Parse the component folder name from the path to the item
					String[] folders = repositoryItem.repositoryItem.getPath().split("/");
					String folderName = folders[folders.length - 2];
					componentName = folderName + "/" + componentName;
				}
				packageTypeMembers.add(componentName);
			}
		}
	}

	/**
	 * Print out any errors, if any, related to the deploy.
	 * 
	 * @param result - DeployResult
	 */
	private static String printErrors(DeployResult result) {
		System.out.println("DeployResult: " + result.toString());
		DeployMessage messages[] = result.getMessages();
		StringBuilder buf = new StringBuilder();
		for (DeployMessage message : messages) {
			if (!message.isSuccess()) {
				System.out.println("printErrors: " + message.toString());
				if (buf.length() == 0)
					buf = new StringBuilder("\nFailures:\n");
				String loc = (message.getLineNumber() == 0 ? ""
						: ("(" + message.getLineNumber() + "," + message.getColumnNumber() + ")"));
				if (loc.length() == 0 && !message.getFileName().equals(message.getFullName())) {
					loc = "(" + message.getFullName() + ")";
				}
				buf.append(message.getFileName() + loc + ":" + message.getProblem()).append('\n');
			}
		}
		RunTestsResult rtr = result.getRunTestResult();
		if (rtr.getFailures() != null) {
			for (RunTestFailure failure : rtr.getFailures()) {
				String n = (failure.getNamespace() == null ? "" : (failure.getNamespace() + ".")) + failure.getName();
				buf.append("Test failure, method: " + n + "." + failure.getMethodName() + " -- " + failure.getMessage()
						+ " stack " + failure.getStackTrace() + "\n\n");
			}
		}
		if (rtr.getCodeCoverageWarnings() != null) {
			for (CodeCoverageWarning ccw : rtr.getCodeCoverageWarnings()) {
				buf.append("Code coverage issue");
				if (ccw.getName() != null) {
					String n = (ccw.getNamespace() == null ? "" : (ccw.getNamespace() + ".")) + ccw.getName();
					buf.append(", class: " + n);
				}
				buf.append(" -- " + ccw.getMessage() + "\n");
			}
		}
		return buf.toString();
	}
	
	private void updateStaticVariables(org.json.simple.JSONArray deployList) {
		 String s = "";
		 for (int i = 0 ; i < deployList.size(); i++) {
			 	org.json.simple.JSONObject obj = (org.json.simple.JSONObject) deployList.get(i);
		        s = (String) obj.get("name");
		        if (s.equals("FieloPLT")) {
		        	s = (String) obj.get("version");
		        	String[] lstVersion= s.split("\\.");
		        	MajorVersion = Integer.parseInt(lstVersion[0]);
		        	MinorVersion = Integer.parseInt(lstVersion[1]);
		        	if (lstVersion.length == 3) {
		        		PatchVersion = Integer.parseInt(lstVersion[2]);
		        		}
		        	}
		        	
		        	
		    }
		
	}
	
	
}
