from rest_framework.renderers import JSONRenderer
import json


class UnicodeJSONRenderer(JSONRenderer):
    """
    Custom JSON renderer that ensures proper Unicode/emoji handling
    """
    
    def render(self, data, accepted_media_type=None, renderer_context=None):
        """
        Render `data` into JSON, ensuring Unicode characters are properly handled.
        """
        if data is None:
            return b''

        renderer_context = renderer_context or {}
        indent = self.get_indent(accepted_media_type, renderer_context)

        ret = json.dumps(
            data, 
            cls=self.encoder_class,
            indent=indent, 
            ensure_ascii=False,  # This is key for emoji support
            allow_nan=not self.strict,
            separators=(',', ':') if indent is None else (',', ': ')
        )

        # On python 2.x json.dumps() returns bytestrings if ensure_ascii=True,
        # but if ensure_ascii=False, the return type is underspecified,
        # and may (or may not) be unicode.
        # On python 3.x json.dumps() returns unicode strings.
        if isinstance(ret, str):
            # We always fully encode the response on Python 3.x
            return ret.encode('utf-8')
        return ret