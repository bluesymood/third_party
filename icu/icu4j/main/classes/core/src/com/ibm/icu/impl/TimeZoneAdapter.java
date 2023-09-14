// © 2016 and later: Unicode, Inc. and others.
// License & terms of use: http://www.unicode.org/copyright.html
/*
 **********************************************************************
 * Copyright (c) 2003-2010, International Business Machines
 * Corporation and others.  All Rights Reserved.
 **********************************************************************
 * Author: Alan Liu
 * Created: October 2 2003
 * Since: ICU 2.8
 **********************************************************************
 */

package com.ibm.icu.impl;
import java.util.Date;

import com.ibm.icu.util.TimeZone;

/**
 * <code>TimeZoneAdapter</code> wraps a com.ibm.icu.util.TimeZone
 * subclass and inherits from java.util.TimeZone.
 * Without this class, we would need to 'port' java.util.Date to
 * com.ibm.icu.util as well, so that Date could interoperate properly
 * with the com.ibm.icu.util TimeZone and Calendar classes.  With this
 * class, we can use java.util.Date together with com.ibm.icu.util
 * classes.
 *
 * @see com.ibm.icu.util.TimeZone#setDefault
 * @author Alan Liu
 * @since ICU 2.8
 */
public class TimeZoneAdapter extends java.util.TimeZone {

    // Generated by serialver from JDK 1.4.1_01
    static final long serialVersionUID = -2040072218820018557L;

    /**
     * The contained com.ibm.icu.util.TimeZone object.  Must not be null.
     * We delegate all methods to this object.
     */
    private TimeZone zone;

    /**
     * Given a java.util.TimeZone, wrap it in the appropriate adapter
     * subclass of com.ibm.icu.util.TimeZone and return the adapter.
     */
    public static java.util.TimeZone wrap(com.ibm.icu.util.TimeZone tz) {
        return new TimeZoneAdapter(tz);
    }

    /**
     * Return the java.util.TimeZone wrapped by this object.
     */
    public com.ibm.icu.util.TimeZone unwrap() {
        return zone;
    }

    /**
     * Constructs an adapter for a com.ibm.icu.util.TimeZone object.
     */
    public TimeZoneAdapter(TimeZone zone) {
        this.zone = zone;
        super.setID(zone.getID());
    }

    /**
     * TimeZone API; calls through to wrapped time zone.
     */
    @Override
    public void setID(String ID) {
        super.setID(ID);
        zone.setID(ID);
    }

    /**
     * TimeZone API; calls through to wrapped time zone.
     */
    @Override
    public boolean hasSameRules(java.util.TimeZone other) {
        return other instanceof TimeZoneAdapter &&
            zone.hasSameRules(((TimeZoneAdapter)other).zone);
    }

    /**
     * TimeZone API; calls through to wrapped time zone.
     */
    @Override
    public int getOffset(int era, int year, int month, int day, int dayOfWeek,
                         int millis) {
        return zone.getOffset(era, year, month, day, dayOfWeek, millis);
    }

    /**
     * TimeZone API; calls through to wrapped time zone.
     */
    @Override
    public int getRawOffset() {
        return zone.getRawOffset();
    }

    /**
     * TimeZone API; calls through to wrapped time zone.
     */
    @Override
    public void setRawOffset(int offsetMillis) {
        zone.setRawOffset(offsetMillis);
    }

    /**
     * TimeZone API; calls through to wrapped time zone.
     */
    @Override
    public boolean useDaylightTime() {
        return zone.useDaylightTime();
    }

    /**
     * TimeZone API; calls through to wrapped time zone.
     */
    @Override
    public boolean inDaylightTime(Date date) {
        return zone.inDaylightTime(date);
    }

    /**
     * Boilerplate API; calls through to wrapped object.
     */
    @Override
    public Object clone() {
        return new TimeZoneAdapter((TimeZone)zone.clone());
    }

    /**
     * Boilerplate API; calls through to wrapped object.
     */
    @Override
    public synchronized int hashCode() {
        return zone.hashCode();
    }

    /**
     * Boilerplate API; calls through to wrapped object.
     */
    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj instanceof TimeZoneAdapter) {
            TimeZone anotherZone = ((TimeZoneAdapter) obj).zone;
            return zone.equals(anotherZone);
        }
        return false;
    }

    /**
     * Returns a string representation of this object.
     * @return  a string representation of this object.
     */
    @Override
    public String toString() {
        return "TimeZoneAdapter: " + zone.toString();
    }
}
