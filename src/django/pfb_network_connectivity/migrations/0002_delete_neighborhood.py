# -*- coding: utf-8 -*-
# Generated by Django 1.10.3 on 2017-02-24 16:39
from __future__ import unicode_literals

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0003_auto_20170224_1639'),
        ('pfb_network_connectivity', '0001_initial'),
    ]

    operations = [
        migrations.DeleteModel(
            name='Neighborhood',
        ),
    ]
