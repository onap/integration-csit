from string import Template

class StringTemplater:
    """StringTemplater is common resource for templating with strings."""
    
    def template_string(self, template, values):
        """Template String takes in a string and its values and converts it using the string.Template class"""
        return Template(template).substitute(values) 