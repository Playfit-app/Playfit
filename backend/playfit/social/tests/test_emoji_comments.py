"""
Tests for emoji handling in comments
"""
import json
import tempfile
from django.test import TestCase, override_settings
from django.contrib.auth import get_user_model

from social.models import Post, Comment
from social.serializers import CommentSerializer
from utilities.renderers import UnicodeJSONRenderer

User = get_user_model()
TEMP_MEDIA_ROOT = tempfile.mkdtemp()


@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class EmojiCommentModelTests(TestCase):
    """Test emoji storage and retrieval at the model level"""
    
    def setUp(self):
        self.user = User.objects.create_user(
            email="test@example.com",
            username="testuser",
            password="testpass123",
            date_of_birth="1990-01-01",
            height=175,
            weight=70
        )
        self.post = Post.objects.create(
            user=self.user,
            content="Test post"
        )
    
    def test_simple_emoji_storage(self):
        """Test storing and retrieving simple emojis"""
        emoji_content = "Hello! 😀"
        comment = Comment.objects.create(
            user=self.user,
            post=self.post,
            content=emoji_content
        )
        
        # Test storage
        self.assertEqual(comment.content, emoji_content)
        
        # Test retrieval from database
        retrieved_comment = Comment.objects.get(pk=comment.pk)
        self.assertEqual(retrieved_comment.content, emoji_content)
    
    def test_multiple_emojis_storage(self):
        """Test storing multiple emojis in sequence"""
        emoji_content = "Party time! 🎉🎊🎈🎁"
        comment = Comment.objects.create(
            user=self.user,
            post=self.post,
            content=emoji_content
        )
        
        self.assertEqual(comment.content, emoji_content)
        
        # Verify specific emojis are preserved
        self.assertIn("🎉", comment.content)
        self.assertIn("🎊", comment.content)
        self.assertIn("🎈", comment.content)
        self.assertIn("🎁", comment.content)
    
    def test_mixed_content_with_emojis(self):
        """Test mixed text and emoji content"""
        emoji_content = "Great post! 👍 Really love it ❤️ Thanks for sharing! 🙏"
        comment = Comment.objects.create(
            user=self.user,
            post=self.post,
            content=emoji_content
        )
        
        self.assertEqual(comment.content, emoji_content)
        
        # Verify both text and emojis are preserved
        self.assertIn("Great post!", comment.content)
        self.assertIn("👍", comment.content)
        self.assertIn("❤️", comment.content)
        self.assertIn("🙏", comment.content)
    
    def test_complex_emojis_storage(self):
        """Test complex emojis including skin tones and compound emojis"""
        emoji_content = "Hello! 👋🏽 Family: 👨‍👩‍👧‍👦 Flag: 🏳️‍🌈"
        comment = Comment.objects.create(
            user=self.user,
            post=self.post,
            content=emoji_content
        )
        
        self.assertEqual(comment.content, emoji_content)
    
    def test_emoji_edge_cases(self):
        """Test edge cases with emojis"""
        test_cases = [
            "😀",  # Single emoji
            "😀😀😀",  # Repeated emojis
            "Text😀Text",  # Emoji without spaces
            "😀 😀 😀",  # Emojis with spaces
            "",  # Empty string
            "No emojis here",  # Text only
        ]
        
        for i, content in enumerate(test_cases):
            comment = Comment.objects.create(
                user=self.user,
                post=self.post,
                content=content
            )
            self.assertEqual(comment.content, content, f"Failed for case {i}: {content}")


@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class EmojiCommentSerializerTests(TestCase):
    """Test emoji handling in serializers"""
    
    def setUp(self):
        self.user = User.objects.create_user(
            email="test@example.com",
            username="testuser",
            password="testpass123",
            date_of_birth="1990-01-01",
            height=175,
            weight=70
        )
        self.post = Post.objects.create(
            user=self.user,
            content="Test post"
        )
    
    def test_emoji_serialization(self):
        """Test that emojis are properly serialized"""
        emoji_content = "Amazing work! 🚀⭐🌟✨"
        comment = Comment.objects.create(
            user=self.user,
            post=self.post,
            content=emoji_content
        )
        
        serializer = CommentSerializer(comment)
        serialized_data = serializer.data
        
        # Access content field from serialized data
        content_field = None
        if hasattr(serialized_data, 'get'):
            content_field = serialized_data.get('content')
        elif isinstance(serialized_data, dict):
            content_field = serialized_data['content']
        else:
            # Handle ReturnDict or other DRF data types
            content_field = dict(serialized_data).get('content')
        
        self.assertEqual(content_field, emoji_content)
    
    def test_emoji_deserialization(self):
        """Test that emojis are properly deserialized"""
        emoji_content = "Love this! ❤️💖💕"
        data = {
            'content': emoji_content
        }
        
        serializer = CommentSerializer(data=data)
        self.assertTrue(serializer.is_valid())
        
        comment = serializer.save(user=self.user, post=self.post)
        self.assertEqual(comment.content, emoji_content)
    
    def test_unicode_json_renderer(self):
        """Test custom Unicode JSON renderer"""
        emoji_content = "Test renderer! 😀🎉❤️👍"
        comment = Comment.objects.create(
            user=self.user,
            post=self.post,
            content=emoji_content
        )
        
        serializer = CommentSerializer(comment)
        renderer = UnicodeJSONRenderer()
        
        # Test rendering
        rendered_json = renderer.render(serializer.data)
        
        # Decode and parse the JSON
        json_str = rendered_json.decode('utf-8')
        parsed_data = json.loads(json_str)
        
        self.assertEqual(parsed_data['content'], emoji_content)
        
        # Verify emojis are not escaped in the JSON string
        self.assertIn('😀', json_str)
        self.assertIn('🎉', json_str)
        self.assertNotIn('\\u', json_str)  # Should not contain Unicode escapes
    
    def test_various_emoji_categories(self):
        """Test different categories of emojis"""
        emoji_tests = [
            ("Faces: 😀😃😄😁", "faces"),
            ("Hearts: ❤️💙💚💛", "hearts"),
            ("Objects: 📱💻🖥️⌚", "objects"),
            ("Nature: 🌍🌎🌏🌕", "nature"),
            ("Food: 🍎🍕🍔🍟", "food"),
            ("Sports: ⚽🏀🏈⚾", "sports"),
            ("Vehicles: 🚗🚙🚐🚛", "vehicles"),
            ("Symbols: ✨⭐💫🌟", "symbols"),
        ]
        
        for emoji_content, category in emoji_tests:
            with self.subTest(category=category):
                comment = Comment.objects.create(
                    user=self.user,
                    post=self.post,
                    content=emoji_content
                )
                
                serializer = CommentSerializer(comment)
                serialized_data = dict(serializer.data)
                self.assertEqual(serialized_data.get('content'), emoji_content)





class EmojiUtilityTests(TestCase):
    """Test utility functions for emoji handling"""
    
    def test_unicode_json_renderer_edge_cases(self):
        """Test edge cases for the Unicode JSON renderer"""
        renderer = UnicodeJSONRenderer()
        
        # Test None data
        result = renderer.render(None)
        self.assertEqual(result, b'')
        
        # Test empty data
        result = renderer.render({})
        self.assertIsInstance(result, bytes)
        
        # Test data with various Unicode characters
        test_data = {
            'emojis': '�🎉❤️',
            'accents': 'café naïve résumé',
            'symbols': '™®©',
            'currency': '€£¥₹',
            'math': '∑∏∆√',
        }
        
        result = renderer.render(test_data)
        self.assertIsInstance(result, bytes)
        
        # Parse back and verify
        json_str = result.decode('utf-8')
        parsed = json.loads(json_str)
        
        for key, value in test_data.items():
            self.assertEqual(parsed[key], value)
    
    def test_emoji_preservation_in_json(self):
        """Test that emojis are preserved correctly in JSON serialization"""
        test_cases = [
            "�",  # Simple emoji
            "👨‍👩‍👧‍👦",  # Compound emoji (family)
            "🏳️‍🌈",  # Flag with modifier
            "👋🏽",  # Emoji with skin tone
            "😀🎉",  # Multiple emojis
            "Hello 😀 World 🎉",  # Mixed content
        ]
        
        renderer = UnicodeJSONRenderer()
        
        for content in test_cases:
            with self.subTest(content=content):
                comment_data = {'content': content}
                result = renderer.render(comment_data)
                
                # Verify result is bytes
                self.assertIsInstance(result, bytes)
                
                # Parse back and verify content is preserved
                parsed = json.loads(result.decode('utf-8'))
                self.assertEqual(parsed['content'], content)
                
                # Verify emojis are not escaped in JSON string
                json_str = result.decode('utf-8')
                if any(ord(c) > 127 for c in content):  # Has Unicode characters
                    # Should not contain Unicode escape sequences for basic emojis
                    self.assertNotIn('\\u00', json_str)
    
    def test_emoji_database_roundtrip(self):
        """Test emoji storage and retrieval roundtrip"""
        user = User.objects.create_user(
            email="test@example.com",
            username="testuser",
            password="testpass123",
            date_of_birth="1990-01-01",
            height=175,
            weight=70
        )
        post = Post.objects.create(user=user, content="Test post")
        
        emoji_content = "Full roundtrip test! 🔄🔃⚡💫✨🌟⭐🎯"
        
        # Create comment
        comment = Comment.objects.create(
            user=user,
            post=post,
            content=emoji_content
        )
        
        # Retrieve from database
        retrieved_comment = Comment.objects.get(pk=comment.pk)
        self.assertEqual(retrieved_comment.content, emoji_content)
        
        # Serialize
        serializer = CommentSerializer(retrieved_comment)
        serialized_data = dict(serializer.data)
        
        # Render to JSON
        renderer = UnicodeJSONRenderer()
        json_result = renderer.render(serialized_data)
        
        # Parse back
        parsed_data = json.loads(json_result.decode('utf-8'))
        
        # Verify content is preserved throughout the entire process
        self.assertEqual(parsed_data['content'], emoji_content)