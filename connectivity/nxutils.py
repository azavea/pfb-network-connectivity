# -*- coding: utf-8 -*-

"""
***************************************************************************
    dbutils.py
    ---------------------
    Date                 : October 2015
    Copyright            : (C) 2015 by Spencer Gardner
    Email                : spencergardner at gmail dot com
***************************************************************************
*                                                                         *
*   This program is free software; you can redistribute it and/or modify  *
*   it under the terms of the GNU General Public License as published by  *
*   the Free Software Foundation; either version 2 of the License, or     *
*   (at your option) any later version.                                   *
*                                                                         *
***************************************************************************
"""

__author__ = 'Spencer Gardner'
__date__ = 'October 2015'
__copyright__ = '(C) 2015, Spencer Gardner'

# This will get replaced with a git SHA1 when you do a git archive

__revision__ = '$Format:%H$'

import psycopg2
import networkx as nx

class NXUtils:
    def __init__(self, prefix, zipCode):
        # set up connection
        self.conn = psycopg2.connect("host=192.168.1.144 dbname=people_for_bikes user=gis password=gis")

        # layers
        self.vertsTable = prefix + '_ways_net_vert'
        self.linksTable = prefix + '_ways_net_link'
        self.zipsTable = prefix + '_zip_codes'

        # other vars
        self.zipCode = zipCode
        self.DG = nx.DiGraph()

    def buildNetwork(self):
        # edges
        edgeCur = self.conn.cursor()
        edgeCur.execute('\
            SELECT  links.source_vert, \
                    links.target_vert, \
                    COALESCE(links.link_cost,0), \
                    links.link_id, \
                    COALESCE(links.link_stress,99), \
                    links.int_id \
            FROM    ' + self.linksTable + ' links \
            WHERE   EXISTS ( \
                        SELECT  1 \
                        FROM    ' + self.zipsTable + ' zips \
                        WHERE   zips.zip_code = \'' + self.zipCode + '\' \
                        AND     ST_Intersects(zips.geom,links.geom) \
            ) \
        ')
        for record in edgeCur:
            self.DG.add_edge(
                int(record[0]),
                int(record[1]),
                weight=record[2],
                link_id=record[3],
                stress=record[4],
                int_id=record[5]
            )

        # vertices
        vertCur = self.conn.cursor()
        vertCur.execute('\
            SELECT  verts.vert_id, \
                    COALESCE(verts.vert_cost,0), \
                    verts.road_id \
            FROM    ' + self.vertsTable + ' verts \
            WHERE   EXISTS ( \
                        SELECT  1 \
                        FROM    ' + self.zipsTable + ' zips \
                        WHERE   zips.zip_code = \'' + self.zipCode + '\' \
                        AND     ST_Intersects(zips.geom,verts.geom) \
            ) \
        ')
        for record in vertCur:
            vid = record[0]
            self.DG.node[vid]['weight'] = record[1]
            self.DG.node[vid]['road_id'] = record[2]

    def getNetwork(self):
        return self.DG

    def getStressNetwork(self,stress):
        '''SG = nx.DiGraph()
        SG = nx.DiGraph( [ (u,v,d) for u,v,d in self.DG.edges(data=True) if d['stress'] <= stress ] )
        for v in SG.nodes():
            SG.node[v]['weight'] = self.DG.node[v].get('weight')
            SG.node[v]['int_id'] = self.DG.node[v].get('int_id')
        return SG'''

        nodeList = []
        for v in self.DG.nodes():
            if self.DG.node[v].get('stress') <= stress:
                nodeList.append(v)
        SG = self.DG.subgraph(nodeList)
        return SG
