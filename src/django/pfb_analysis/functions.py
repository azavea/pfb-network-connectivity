from django.db.models.expressions import Func


class ObjectAtPath(Func):
    """ Database function to extract an object or value from a JSONField """
    function = '#>'
    template = "%(expressions)s%(function)s'{%(path)s}'"
    arity = 1

    def __init__(self, expression, path, **extra):
        # if path is a list, convert it to a comma separated string
        if isinstance(path, (list, tuple)):
            path = ','.join(path)
        super(ObjectAtPath, self).__init__(expression, path=path, **extra)
