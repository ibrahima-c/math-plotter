package fr.servlets;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import fr.exceptions.DivisionException;
import fr.exceptions.MathFunctionException;
import fr.exceptions.ParenthesisException;
import fr.graphs.Graph;
import fr.graphs.IGraph;

@WebServlet( urlPatterns = { "/plot2d", "" } )
public class PlotServlet extends HttpServlet {

    private static final long serialVersionUID = 6240711147031459765L;

    @Override
    protected void doGet( HttpServletRequest req, HttpServletResponse resp ) throws ServletException, IOException {

        String expression = "cos(pi*x)";
        Double xmin = -1.0;
        Double xmax = 1.0;

        req.setAttribute( "xmin", xmin );
        req.setAttribute( "xmax", xmax );
        req.setAttribute( "expression", expression );

        req.getRequestDispatcher( "/WEB-INF/plot.jsp" ).forward( req, resp );
    }

    @Override
    protected void doPost( HttpServletRequest req, HttpServletResponse resp ) throws ServletException, IOException {

        String expression = null;
        Double xmin = null, xmax = null;

        Integer nbPoints = 1000;

        List<String> errors = new ArrayList<>();

        try {

            expression = req.getParameter( "expression" );
            xmin = Double.parseDouble( req.getParameter( "xmin" ) );
            xmax = Double.parseDouble( req.getParameter( "xmax" ) );

            req.setAttribute( "xmin", xmin );
            req.setAttribute( "xmax", xmax );
            req.setAttribute( "expression", expression );

            IGraph graph = new Graph( expression, xmin, xmax, nbPoints );

            req.setAttribute( "x", graph.getXaxis() );
            req.setAttribute( "F", graph.getFx() );
            req.setAttribute( "nbPoints", nbPoints );

            req.setAttribute( "ymax", Utils.findMax( graph.getFx() ) );
            req.setAttribute( "ymin", Utils.findMin( graph.getFx() ) );

            req.setAttribute( "success", "Done..." );

        } catch ( NullPointerException | NumberFormatException | MathFunctionException | DivisionException
                | ParenthesisException e ) {

            errors.add( e.getMessage() );
            req.setAttribute( "errors", errors );

            req.setAttribute( "xmin", xmin );
            req.setAttribute( "xmax", xmax );
            req.setAttribute( "expression", expression );
        }

        req.getRequestDispatcher( "/WEB-INF/plot.jsp" ).forward( req, resp );

    }

}
