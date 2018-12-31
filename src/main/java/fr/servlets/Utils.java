package fr.servlets;

public class Utils {

    public static Double findMax( Double[] array ) {

        Double max = null;

        if ( array != null && array.length > 0 ) {
            max = array[0];
            for ( Double o : array ) {
                if ( o > max )
                    max = o;
            }
        }

        return max;
    }

    public static Double findMin( Double[] array ) {

        Double min = null;

        if ( array != null && array.length > 0 ) {
            min = array[0];
            for ( Double o : array ) {
                if ( o < min )
                    min = o;
            }
        }

        return min;
    }

}
