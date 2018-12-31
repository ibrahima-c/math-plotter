
<!DOCTYPE html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<html>
<%
    String ctxPath = request.getContextPath();
			java.util.List<String> jsList = new java.util.ArrayList<>();
%>
<head>
<meta charset="UTF-8">
<title>math-plotter</title>
<link href="<%=ctxPath%>/css/bootstrap.min.css" rel="stylesheet" />
<link href="<%=ctxPath%>/css/style.css" rel="stylesheet" />
</head>
<body>

	<div class="container">

		<div class="row">
			<h1>Mathematical expression plotter</h1>

			<c:if test="${not empty errors}">
				<div class="alert alert-danger" style="color: red;">
					<span>ERROR : </span>
					<ul>
						<c:forEach items="${errors}" var="error">
							<li>${error}</li>
						</c:forEach>
					</ul>
				</div>
			</c:if>

			<c:if test="${not empty success}">
				<div class="alert alert-success" style="color: green;">${success}</div>
			</c:if>
		</div>



		<div class="row">
			<c:url var="post_url" value="/plot2d" />
			<form method="post" action="${post_url}">

				<div class="form-group">
					<label for="expression">Expression : </label> <input class="form-control" type="text" name="expression" id="expression" value="${expression}">
				</div>

				<div class="form-group">
					<label for="xmin">xMin : </label> <input class="form-control" type="text" name="xmin" id="xmin" value="${xmin}">
				</div>

				<div class="form-group">
					<label for="xmax">xMax : </label> <input class="form-control" type="text" name="xmax" id="xmax" value="${xmax}">
				</div>

				<input class="btn btn-primary" type="submit" value="Plot">

				<div class="form-group">
					<label for="ymin">yMin : </label> <input readonly class="form-control" type="text" name="ymin" id="ymin" value="<fmt:formatNumber type = "number" 
         groupingUsed = "false" value = "${ymin}" />">
				</div>

				<div class="form-group">
					<label for="ymax">yMax : </label> <input readonly class="form-control" type="text" name="ymax" id="ymax" value="<fmt:formatNumber type = "number" 
         groupingUsed = "false" value = "${ymax}" />">
				</div>

			</form>
		</div>

		<div class="row">
			<canvas id="xy-graph"></canvas>
		</div>
	</div>

	<script>
		/* Initialization */

		var nbPoints = "${nbPoints}";
		x = new Array(nbPoints);
		y = new Array(nbPoints);
	<%Integer nbPoints = (Integer) request.getAttribute("nbPoints");%>
		
	<%Double[] x = (Double[]) request.getAttribute("x");%>
		
	<%Double[] y = (Double[]) request.getAttribute("F");%>
		
	<%if (nbPoints != null && nbPoints > 0) {%>
		
	<%for (int i = 0; i < nbPoints; i++) {%>
		x[
	<%=i%>
		] =
	<%=x[i]%>
		;
		y[
	<%=i%>
		] =
	<%=y[i]%>
		;
	<%}
			}%>
		/* Canvas and context objects */

		var Canvas = document.getElementById('xy-graph');
		var Ctx = null;

		var Width = Canvas.width;
		var Height = Canvas.height;

		//draw

		if (nbPoints > 0) {
			Draw();
		}

		// To be called when the page finishes loading:
		function init() {
			Draw();
		}

		/*
		 The origin (0,0) of the canvas is the upper left:

		 (0,0)
		 --------- +X
		 |
		 |
		 |
		 |
		 +Y

		 Positive x coordinates go to the right, and positive y coordinates go down.

		 The origin in mathematics is the "center," and positive y goes *up*.

		 We'll refer to the mathematics coordinate system as the "logical"
		 coordinate system, and the coordinate system for the canvas as the
		 "physical" coordinate system.

		 The functions just below set up a mapping between the two coordinate
		 systems.

		 They're defined as functions, so that one wanted to, they could read
		 ther values from a from instead of having them hard-coded.

		 */

		// Returns the right boundary of the logical viewport:
		function MaxX() {
			return x[nbPoints - 1];
		}

		// Returns the left boundary of the logical viewport:
		function MinX() {
			return x[0];
		}

		// Returns the top boundary of the logical viewport:
		function MaxY() {
			return Math.max.apply(null, y) + 1;
		}

		// Returns the bottom boundary of the logical viewport:
		function MinY() {
			return Math.min.apply(null, y) - 1;
		}

		// Returns the physical x-coordinate of a logical x-coordinate:
		function XC(x) {
			return (x - MinX()) / (MaxX() - MinX()) * Width;
		}

		// Returns the physical y-coordinate of a logical y-coordinate:
		function YC(y) {
			return Height - (y - MinY()) / (MaxY() - MinY()) * Height;
		}

		/* Rendering functions */

		// Clears the canvas, draws the axes and graphs the function F.
		function Draw() {

			// Evaluate the user-supplied code, which must bind a value to F.
			// eval(document.getElementById('function-code').value) ;

			if (Canvas.getContext) {

				// Set up the canvas:
				Ctx = Canvas.getContext('2d');
				Ctx.clearRect(0, 0, Width, Height);

				// Draw:
				DrawAxes();
				RenderFunction();

			} else {
				// Do nothing.
			}
		}

		// Returns the distance between ticks on the X axis:
		function XTickDelta() {
			return 1;
		}

		// Returns the distance between ticks on the Y axis:
		function YTickDelta() {
			return 1;
		}

		// DrawAxes draws the X ad Y axes, with tick marks.
		function DrawAxes() {
			Ctx.save();
			Ctx.lineWidth = 1;
			// +Y axis
			Ctx.beginPath();
			Ctx.moveTo(XC(0), YC(0));
			Ctx.lineTo(XC(0), YC(MaxY()));
			Ctx.stroke();

			// -Y axis
			Ctx.beginPath();
			Ctx.moveTo(XC(0), YC(0));
			Ctx.lineTo(XC(0), YC(MinY()));
			Ctx.stroke();

			// Y axis tick marks
			var delta = YTickDelta();
			for (var i = 1; (i * delta) < MaxY(); ++i) {
				Ctx.beginPath();
				Ctx.moveTo(XC(0) - 5, YC(i * delta));
				Ctx.lineTo(XC(0) + 5, YC(i * delta));
				Ctx.stroke();
			}

			var delta = YTickDelta();
			for (var i = 1; (i * delta) > MinY(); --i) {
				Ctx.beginPath();
				Ctx.moveTo(XC(0) - 5, YC(i * delta));
				Ctx.lineTo(XC(0) + 5, YC(i * delta));
				Ctx.stroke();
			}

			// +X axis
			Ctx.beginPath();
			Ctx.moveTo(XC(0), YC(0));
			Ctx.lineTo(XC(MaxX()), YC(0));
			Ctx.stroke();

			// -X axis
			Ctx.beginPath();
			Ctx.moveTo(XC(0), YC(0));
			Ctx.lineTo(XC(MinX()), YC(0));
			Ctx.stroke();

			// X tick marks
			var delta = XTickDelta();
			for (var i = 1; (i * delta) < MaxX(); ++i) {
				Ctx.beginPath();
				Ctx.moveTo(XC(i * delta), YC(0) - 5);
				Ctx.lineTo(XC(i * delta), YC(0) + 5);
				Ctx.stroke();
			}

			var delta = XTickDelta();
			for (var i = 1; (i * delta) > MinX(); --i) {
				Ctx.beginPath();
				Ctx.moveTo(XC(i * delta), YC(0) - 5);
				Ctx.lineTo(XC(i * delta), YC(0) + 5);
				Ctx.stroke();
			}
			Ctx.restore();
		}

		// When rendering, XSTEP determines the horizontal distance between points:
		var XSTEP = (MaxX() - MinX()) / Width;

		// RenderFunction(f) renders the input funtion f on the canvas.
		function RenderFunction() {
			var first = true;

			Ctx.beginPath();
			for (var i = 0; i <= nbPoints; i += 1) {
				if (first) {
					Ctx.moveTo(XC(x[i]), YC(y[i]));
					first = false;
				} else {
					Ctx.lineTo(XC(x[i]), YC(y[i]));
				}
			}
			Ctx.strokeStyle = 'blue';
			Ctx.stroke();
		}
	</script>

	<script src="<%= ctxPath %>/js/bootstrap.min.js" type="text/javascript"></script>

</body>
</html>
