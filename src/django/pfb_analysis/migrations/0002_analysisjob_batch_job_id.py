# -*- coding: utf-8 -*-
# Generated by Django 1.10.3 on 2017-03-03 16:19
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('pfb_analysis', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='analysisjob',
            name='batch_job_id',
            field=models.CharField(blank=True, max_length=256, null=True),
        ),
    ]