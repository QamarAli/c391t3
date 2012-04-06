<%@ page import="java.sql.*" %>
<%
	String error = "";
	if(session.getAttribute("name") != null && request.getParameter("rSubmit") != null){
    	//establish the connection to the underlying database
		Connection conn = null;
    	String driverName = "oracle.jdbc.driver.OracleDriver";
    	String dbstring = "jdbc:oracle:thin:@gwynne.cs.ualberta.ca:1521:CRS";

    	try{
        	//load and register the driver
			Class drvClass = Class.forName(driverName); 
    		DriverManager.registerDriver((Driver) drvClass.newInstance());
    		//establish the connection 
    		if(session.getAttribute("dbuser") != null){
    			String dbUser = (String) session.getAttribute("dbuser");
    			String dbPass = (String) session.getAttribute("dbpass");
    			conn = DriverManager.getConnection(dbstring, dbUser, dbPass);
    		}
    		else
        		conn = DriverManager.getConnection(dbstring,"cwarkent","lotr0808pso");
			conn.setAutoCommit(false);
		}
    	catch(Exception ex){
        	out.println("<hr>" + ex.getMessage() + "<hr>");
    	}

    	String userName = (String) session.getAttribute("name");
		String patname = request.getParameter("patname");
		String docname = request.getParameter("docname");
		String testtype = request.getParameter("testtype");
		String presdate = request.getParameter("presdate");
		String testdate = request.getParameter("testdate");
		String diag = request.getParameter("diag");
		String desc = request.getParameter("desc");

    	//select the user table from the underlying db and update persons
    	Statement recstmt = conn.createStatement();
		ResultSet recrset = recstmt.executeQuery("SELECT record_seq.nextval from dual");
		recrset.next();
		int recid = recrset.getInt(1);
		
		PreparedStatement stmt = null;
    	ResultSet rset = null;
		String sql = "insert into radiology_record values("+recid+",?,?,?,?,?,?,?,?)";
		try{
			stmt = conn.prepareStatement(sql);
    		stmt.setString(1, patname);
    		stmt.setString(2, docname);
    		stmt.setString(3, userName);
    		stmt.setString(4, testtype);
    		stmt.setString(5, presdate);
    		stmt.setString(6, testdate);
    		stmt.setString(7, diag);
    		stmt.setString(8, desc);
	        stmt.executeUpdate();
	        
	        Statement seqstmt = conn.createStatement();
			seqstmt.executeQuery("CREATE SEQUENCE pic_seq_"+recid);

	        conn.commit();
	        response.sendRedirect("uploadAfter.jsp?recid="+recid+"&result=recok");
		}
    	catch(Exception ex){
        	error = ex.getMessage();
		}
	    	
		try{
        	conn.close();
     	}
        catch(Exception ex){
       		error = ex.getMessage();
        }
	}
	else
		error = "You are not signed in or did not submit";

	if(!error.equals("")){
		String title = "Upload Record";
%>
<%@ include file="header.jsp" %>
		<div id="main">
		<%= error %>
		</div>
	</BODY>
</HTML>
<%
	}
%>
