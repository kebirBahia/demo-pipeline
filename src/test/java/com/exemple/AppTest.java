package com.exemple;

import static org.junit.Assert.assertEquals;
import org.junit.Test;

public class AppTest {

    @Test
    public void testAddition() {
        assertEquals(6, App.addition(2,3));
    }

    @Test
    public void testAdditionAvecZero() {
        assertEquals(7, App.addition(7, 0));
    }

    @Test
    public void testAdditionNegatifs() {
        assertEquals(-5, App.addition(-2, -3));
    }
}
