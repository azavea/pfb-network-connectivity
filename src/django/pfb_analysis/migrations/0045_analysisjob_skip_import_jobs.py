# Generated by Django 3.2.13 on 2022-07-01 20:04

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('pfb_analysis', '0044_analysisjob_population_url'),
    ]

    operations = [
        migrations.AddField(
            model_name='analysisjob',
            name='skip_import_jobs',
            field=models.BooleanField(default=False),
        ),
    ]