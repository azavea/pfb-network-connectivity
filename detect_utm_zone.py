#!/usr/bin/env python

"""
Accepts a polygon shapefile in WGS84 and finds the SRID for the UTM zone
Based on https://github.com/jbranigan/geo-scripts-python/blob/master/latlng2utm/detect-utm-zone.py
"""

from osgeo import ogr
import math
import argparse


def check_latlng(check_bbox):
    ''' Checks to see if the file coordinates are in lat/lng '''
    for i in check_bbox:
        if i < -180 or i > 180:
            failure('This file is already projected.')
    return True


def check_width(check_bbox):
    ''' Checsk to see if the bounding box fits in a UTM zone '''
    wide = check_bbox[1] - check_bbox[0]
    if wide > 3:
        failure('This file is too many degrees wide for UTM')
    return True


def get_zone(coord):
    ''' Finds the UTM zone of the coordinate '''
    # There are 60 longitudinal projection zones numbered 1 to 60 starting at 180W
    # So that's -180 = 1, -174 = 2, -168 = 3
    zone = ((coord - -180) / 6.0)
    return int(math.ceil(zone))


def get_bbox(shapefile):
    ''' Gets the bounding box of a shapefile input '''
    driver = ogr.GetDriverByName('ESRI Shapefile')
    # 0 means read, 1 means write
    data_source = driver.Open(shapefile, 0)
    # Check to see if shapefile is found.
    if data_source is None:
        failure('Could not open %s' % (shapefile))
    else:
        layer = data_source.GetLayer()
        shape_bbox = layer.GetExtent()
        return shape_bbox


def failure(why):
    ''' Quits the script with an exit message '''
    print why
    raise SystemExit


def get_srid(filename):
    bbox = get_bbox(filename)
    check_latlng(bbox)
    check_width(bbox)

    avg_longitude = ((bbox[1] - bbox[0]) / 2) + bbox[0]
    utm_zone = get_zone(avg_longitude)

    avg_latitude = ((bbox[3] - bbox[2]) / 2) + bbox[2]

    # convert UTM zone to SRID
    # SRID for a given UTM ZONE: 32[6 if N|7 if S]<zone>
    srid = '32'
    if avg_latitude < 0:
        srid += '7'
    else:
        srid += '6'

    srid += str(utm_zone)
    print(srid)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("filename", help="the path to the input shapefile")
    args = parser.parse_args()

    get_srid(args.filename)

main()
