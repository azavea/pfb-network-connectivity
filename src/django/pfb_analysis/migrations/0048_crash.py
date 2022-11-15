# Generated by Django 3.2.13 on 2022-12-01 20:27

import django.contrib.gis.db.models.fields
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('pfb_analysis', '0047_neighborhood_speed_limit'),
    ]

    operations = [
        migrations.CreateModel(
            name='Crash',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('fatality_count', models.IntegerField()),
                ('fatality_type', models.CharField(choices=[('ACTIVE', 'Other Active Transport'), ('BIKE', 'Bike'), ('MOTOR_VEHICLE', 'Motor Vehicle')], max_length=16)),
                ('geom_pt', django.contrib.gis.db.models.fields.PointField(srid=4326)),
                ('year', models.IntegerField()),
            ],
        ),
    ]
