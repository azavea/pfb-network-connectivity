from django.conf import settings
import pycountry


def get_country_config(alpha_2):
    return settings.COUNTRY_CONFIG.get(alpha_2, settings.COUNTRY_CONFIG['default'])


def use_subdivisions(alpha_2):
    return settings.COUNTRY_CONFIG.get(alpha_2, settings.COUNTRY_CONFIG['default'])['subdivisions']


def subdivisions_for_country(alpha_2):
    """ Subdivisions for the given country, if we want to track them

    Returns a list of subdivisions, as {name, code, type}, for the given country, but
    only if the country config in settings says to track subdivisions for the country. Otherwise
    returns None.
    """
    if use_subdivisions(alpha_2):
        return sorted(
            # Note: pycountry's subdivision codes all start with the alpha_2 country code and
            # a hyphen. Since we're attaching them to the country and don't expect to be
            # mingling subdivisions from different countries, this strips off the prefix and
            # keeps only the actual subdivision code.
            [{'name': s.name, 'code': s.code[3:], 'type': s.type} for s in
             pycountry.subdivisions.get(country_code=alpha_2)],
            key=lambda s: s['name']
        )
    return None


def build_country_list():
    """ Build a list of countries, without US territories and with subdivisions if desired

    Builds a list of {alpha_2, name, subdivisions} dictionaries, where 'subdivisions' is
    a dictionary of {code, name, type} subdivisions, but is only present if the country
    config in settings calls for tracking subdivisions for the country.

    US territories are present in both the countries and subdivisions lists in pycountry,
    so we need to get a list of them and filter them out of the countries list.
    """
    us_territories = [t['code'] for t in subdivisions_for_country('US')
                      if t['type'] == 'Outlying area']
    countries = []
    for country in pycountry.countries:
        if country.alpha_2 in us_territories:
            continue
        country_dict = {'alpha_2': country.alpha_2, 'name': country.name}
        subdivisions = subdivisions_for_country(country.alpha_2)
        if subdivisions is not None:
            country_dict['subdivisions'] = subdivisions
        countries.append(country_dict)
    countries.sort(key=lambda c: c['name'])
    return countries
