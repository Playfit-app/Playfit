from unittest.mock import AsyncMock, patch, Mock
from django.test import TransactionTestCase
from django.contrib.auth.models import AnonymousUser
from django.contrib.auth.hashers import make_password
from rest_framework.authtoken.models import Token
from authentification.models import CustomUser
from social.middleware import TokenAuthMiddleware, get_user_from_token
import asyncio


class TokenAuthMiddlewareTestCase(TransactionTestCase):
    def setUp(self):
        self.user = CustomUser.objects.create(
            email="test@test.com",
            username="testuser",
            password=make_password("testpass123"),
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
            email_hash="testhash1"
        )
        self.token = Token.objects.create(user=self.user)
        self.middleware = TokenAuthMiddleware(AsyncMock())

    @patch('social.middleware.Token.objects.get')
    def test_get_user_from_token_valid_token(self, mock_token_get):
        """Test retrieving user with valid token"""
        mock_token = Mock()
        mock_token.user = self.user
        mock_token_get.return_value = mock_token
        
        async def run_test():
            user = await get_user_from_token(self.token.key)
            self.assertEqual(user, self.user)
            mock_token_get.assert_called_once_with(key=self.token.key)
        
        asyncio.run(run_test())

    @patch('social.middleware.Token.objects.get')
    def test_get_user_from_token_invalid_token(self, mock_token_get):
        """Test retrieving user with invalid token returns AnonymousUser"""
        mock_token_get.side_effect = Token.DoesNotExist()
        
        async def run_test():
            user = await get_user_from_token("invalid_token")
            self.assertIsInstance(user, AnonymousUser)
            mock_token_get.assert_called_once_with(key="invalid_token")
        
        asyncio.run(run_test())

    @patch('social.middleware.Token.objects.get')
    def test_middleware_with_valid_token(self, mock_token_get):
        """Test middleware with valid authorization header"""
        mock_token = Mock()
        mock_token.user = self.user
        mock_token_get.return_value = mock_token
        
        async def run_test():
            scope = {
                "headers": [
                    (b"authorization", f"Token {self.token.key}".encode())
                ]
            }
            receive = AsyncMock()
            send = AsyncMock()
            
            await self.middleware(scope, receive, send)
            
            self.assertEqual(scope["user"], self.user)
            mock_token_get.assert_called_once_with(key=self.token.key)
        
        asyncio.run(run_test())

    @patch('social.middleware.Token.objects.get')
    def test_middleware_with_invalid_token(self, mock_token_get):
        """Test middleware with invalid authorization header"""
        mock_token_get.side_effect = Token.DoesNotExist()
        
        async def run_test():
            scope = {
                "headers": [
                    (b"authorization", b"Token invalid_token")
                ]
            }
            receive = AsyncMock()
            send = AsyncMock()
            
            await self.middleware(scope, receive, send)
            
            self.assertIsInstance(scope["user"], AnonymousUser)
            mock_token_get.assert_called_once_with(key="invalid_token")
        
        asyncio.run(run_test())

    def test_middleware_without_auth_header(self):
        """Test middleware without authorization header"""
        async def run_test():
            scope = {
                "headers": []
            }
            receive = AsyncMock()
            send = AsyncMock()
            
            await self.middleware(scope, receive, send)
            
            self.assertIsInstance(scope["user"], AnonymousUser)
        
        asyncio.run(run_test())

    def test_middleware_with_malformed_auth_header(self):
        """Test middleware with malformed authorization header"""
        async def run_test():
            scope = {
                "headers": [
                    (b"authorization", b"InvalidFormat token123")
                ]
            }
            receive = AsyncMock()
            send = AsyncMock()
            
            await self.middleware(scope, receive, send)
            
            self.assertIsInstance(scope["user"], AnonymousUser)
        
        asyncio.run(run_test())

    def test_middleware_with_empty_headers_dict(self):
        """Test middleware with no headers key in scope"""
        async def run_test():
            scope = {}
            receive = AsyncMock()
            send = AsyncMock()
            
            await self.middleware(scope, receive, send)
            
            self.assertIsInstance(scope["user"], AnonymousUser)
        
        asyncio.run(run_test())

    def test_middleware_with_token_only(self):
        """Test middleware with Token keyword only (no value)"""
        async def run_test():
            scope = {
                "headers": [
                    (b"authorization", b"Token")
                ]
            }
            receive = AsyncMock()
            send = AsyncMock()
            
            await self.middleware(scope, receive, send)
            
            self.assertIsInstance(scope["user"], AnonymousUser)
        
        asyncio.run(run_test())

    def test_middleware_with_bearer_token(self):
        """Test middleware with Bearer token (should not authenticate)"""
        async def run_test():
            scope = {
                "headers": [
                    (b"authorization", f"Bearer {self.token.key}".encode())
                ]
            }
            receive = AsyncMock()
            send = AsyncMock()
            
            await self.middleware(scope, receive, send)
            
            self.assertIsInstance(scope["user"], AnonymousUser)
        
        asyncio.run(run_test())

    @patch('social.middleware.Token.objects.get')
    def test_get_user_from_token_with_database_error(self, mock_token_get):
        """Test get_user_from_token handles database errors gracefully"""
        mock_token_get.side_effect = Exception("Database error")
        
        async def run_test():
            user = await get_user_from_token(self.token.key)
            self.assertIsInstance(user, AnonymousUser)
            mock_token_get.assert_called_once_with(key=self.token.key)
        
        asyncio.run(run_test())

    @patch('social.middleware.Token.objects.get')
    def test_middleware_preserves_scope_structure(self, mock_token_get):
        """Test that middleware preserves existing scope structure"""
        mock_token = Mock()
        mock_token.user = self.user
        mock_token_get.return_value = mock_token
        
        async def run_test():
            scope = {
                "type": "websocket",
                "path": "/ws/notifications/",
                "headers": [
                    (b"authorization", f"Token {self.token.key}".encode()),
                    (b"origin", b"http://localhost:3000")
                ],
                "query_string": b"",
                "existing_key": "should_be_preserved"
            }
            receive = AsyncMock()
            send = AsyncMock()
            
            await self.middleware(scope, receive, send)
            
            # Check that user was added
            self.assertEqual(scope["user"], self.user)
            
            # Check that existing structure is preserved
            self.assertEqual(scope["type"], "websocket")
            self.assertEqual(scope["path"], "/ws/notifications/")
            self.assertEqual(scope["existing_key"], "should_be_preserved")
            self.assertTrue(len(scope["headers"]) == 2)
            mock_token_get.assert_called_once_with(key=self.token.key)
        
        asyncio.run(run_test())
