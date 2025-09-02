import asyncio
from unittest.mock import patch, MagicMock, AsyncMock
from django.test import TestCase
from authentification.models import CustomUser
from social.utils import send_push_notification, send_notification, send_notification_async


class UtilsTestCase(TestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="testuser",
            password="testpass123",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        
    @patch('social.utils.GCMDevice')
    def test_send_push_notification_success(self, mock_gcm_device):
        """Test successful push notification sending"""
        # Create mock device
        mock_device = MagicMock()
        mock_device.send_message.return_value = True
        mock_gcm_device.objects.filter.return_value = [mock_device]
        
        send_push_notification(self.user, "Test Title", "Test Message")
        mock_device.send_message.assert_called_once_with(title="Test Title", message="Test Message")

    @patch('social.utils.GCMDevice')
    def test_send_push_notification_failure_deactivates_device(self, mock_gcm_device):
        """Test that failing devices are deactivated"""
        mock_device = MagicMock()
        mock_device.send_message.side_effect = Exception("Send failed")
        mock_gcm_device.objects.filter.return_value = [mock_device]
        
        send_push_notification(self.user, "Test Title", "Test Message")
        
        # Check that device was deactivated
        self.assertFalse(mock_device.active)
        mock_device.save.assert_called_once()

    @patch('social.utils.GCMDevice')
    def test_send_push_notification_no_devices(self, mock_gcm_device):
        """Test behavior when user has no devices"""
        mock_gcm_device.objects.filter.return_value = []
        
        # Should not raise any exception
        send_push_notification(self.user, "Test Title", "Test Message")

    @patch('social.utils.redis_client')
    @patch('social.utils.async_to_sync')
    @patch('social.utils.get_channel_layer')
    def test_send_notification_user_online(self, mock_get_channel_layer, mock_async_to_sync, mock_redis):
        """Test sending notification to online user via websocket"""
        mock_redis.exists.return_value = True
        mock_channel_layer = MagicMock()
        mock_get_channel_layer.return_value = mock_channel_layer
        mock_group_send = MagicMock()
        mock_async_to_sync.return_value = mock_group_send
        
        notification_data = {
            "notification_type": "like",
            "sender": "sender_user",
            "id": 1
        }
        
        send_notification(self.user, notification_data)
        
        mock_redis.exists.assert_called_once_with(f"user_{self.user.id}")
        mock_async_to_sync.assert_called_once_with(mock_channel_layer.group_send)
        mock_group_send.assert_called_once_with(
            f"notifications_{self.user.id}",
            {
                "type": "send_notification",
                "message": {
                    "data": notification_data,
                },
            },
        )

    @patch('social.utils.send_push_notification')
    @patch('social.utils.redis_client')
    def test_send_notification_user_offline_like(self, mock_redis, mock_send_push):
        """Test sending notification to offline user - like notification"""
        mock_redis.exists.return_value = False
        
        notification_data = {
            "notification_type": "like",
            "sender": "sender_user"
        }
        
        send_notification(self.user, notification_data)
        
        mock_send_push.assert_called_once_with(
            self.user, "Playfit", "sender_user liked your post"
        )

    @patch('social.utils.send_push_notification')
    @patch('social.utils.redis_client')
    def test_send_notification_user_offline_comment(self, mock_redis, mock_send_push):
        """Test sending notification to offline user - comment notification"""
        mock_redis.exists.return_value = False
        
        notification_data = {
            "notification_type": "comment",
            "sender": "sender_user"
        }
        
        send_notification(self.user, notification_data)
        
        mock_send_push.assert_called_once_with(
            self.user, "Playfit", "sender_user commented on your post"
        )

    @patch('social.utils.send_push_notification')
    @patch('social.utils.redis_client')
    def test_send_notification_user_offline_follow(self, mock_redis, mock_send_push):
        """Test sending notification to offline user - follow notification"""
        mock_redis.exists.return_value = False
        
        notification_data = {
            "notification_type": "follow",
            "sender": "sender_user"
        }
        
        send_notification(self.user, notification_data)
        
        mock_send_push.assert_called_once_with(
            self.user, "Playfit", "sender_user followed you"
        )

    @patch('social.utils.send_push_notification')
    @patch('social.utils.redis_client')
    def test_send_notification_user_offline_post(self, mock_redis, mock_send_push):
        """Test sending notification to offline user - post notification"""
        mock_redis.exists.return_value = False
        
        notification_data = {
            "notification_type": "post",
            "sender": "sender_user"
        }
        
        send_notification(self.user, notification_data)
        
        mock_send_push.assert_called_once_with(
            self.user, "Playfit", "sender_user posted"
        )

    def test_send_notification_async_user_online(self):
        """Test async notification sending to online user"""
        async def run_async_test():
            with patch('social.utils.redis_client') as mock_redis, \
                 patch('social.utils.get_channel_layer') as mock_get_channel_layer:
                
                mock_redis.exists.return_value = True
                mock_channel_layer = AsyncMock()
                mock_get_channel_layer.return_value = mock_channel_layer
                
                notification_data = {
                    "notification_type": "like",
                    "sender": "sender_user"
                }
                
                await send_notification_async(self.user, notification_data)
                
                mock_redis.exists.assert_called_once_with(f"user_{self.user.id}")
                mock_channel_layer.group_send.assert_called_once_with(
                    f"notifications_{self.user.id}",
                    {
                        "type": "send_notification",
                        "message": {
                            "data": notification_data,
                        },
                    },
                )
        
        asyncio.run(run_async_test())

    def test_send_notification_async_user_offline_like(self):
        """Test async notification to offline user - like"""
        async def run_async_test():
            with patch('social.utils.sync_to_async') as mock_sync_to_async, \
                 patch('social.utils.redis_client') as mock_redis:
                
                mock_redis.exists.return_value = False
                mock_send_push = AsyncMock()
                mock_sync_to_async.return_value = mock_send_push
                
                notification_data = {
                    "notification_type": "like",
                    "sender": "sender_user"
                }
                
                await send_notification_async(self.user, notification_data)
                
                mock_send_push.assert_called_once_with(
                    self.user, "Playfit", "sender_user liked your post"
                )
        
        asyncio.run(run_async_test())

    def test_send_notification_async_user_offline_comment(self):
        """Test async notification to offline user - comment"""
        async def run_async_test():
            with patch('social.utils.sync_to_async') as mock_sync_to_async, \
                 patch('social.utils.redis_client') as mock_redis:
                
                mock_redis.exists.return_value = False
                mock_send_push = AsyncMock()
                mock_sync_to_async.return_value = mock_send_push
                
                notification_data = {
                    "notification_type": "comment",
                    "sender": "sender_user"
                }
                
                await send_notification_async(self.user, notification_data)
                
                mock_send_push.assert_called_once_with(
                    self.user, "Playfit", "sender_user commented on your post"
                )
        
        asyncio.run(run_async_test())

    def test_send_notification_async_user_offline_follow(self):
        """Test async notification to offline user - follow"""
        async def run_async_test():
            with patch('social.utils.sync_to_async') as mock_sync_to_async, \
                 patch('social.utils.redis_client') as mock_redis:
                
                mock_redis.exists.return_value = False
                mock_send_push = AsyncMock()
                mock_sync_to_async.return_value = mock_send_push
                
                notification_data = {
                    "notification_type": "follow",
                    "sender": "sender_user"
                }
                
                await send_notification_async(self.user, notification_data)
                
                mock_send_push.assert_called_once_with(
                    self.user, "Playfit", "sender_user followed you"
                )
        
        asyncio.run(run_async_test())

    def test_send_notification_async_user_offline_post(self):
        """Test async notification to offline user - post"""
        async def run_async_test():
            with patch('social.utils.sync_to_async') as mock_sync_to_async, \
                 patch('social.utils.redis_client') as mock_redis:
                
                mock_redis.exists.return_value = False
                mock_send_push = AsyncMock()
                mock_sync_to_async.return_value = mock_send_push
                
                notification_data = {
                    "notification_type": "post",
                    "sender": "sender_user"
                }
                
                await send_notification_async(self.user, notification_data)
                
                mock_send_push.assert_called_once_with(
                    self.user, "Playfit", "sender_user posted"
                )
        
        asyncio.run(run_async_test())

    def test_send_notification_async_user_offline_world_position(self):
        """Test async notification to offline user - world position"""
        async def run_async_test():
            with patch('social.utils.sync_to_async') as mock_sync_to_async, \
                 patch('social.utils.redis_client') as mock_redis:
                
                mock_redis.exists.return_value = False
                mock_send_push = AsyncMock()
                mock_sync_to_async.return_value = mock_send_push
                
                notification_data = {
                    "notification_type": "world_position",
                    "sender": "sender_user"
                }
                
                await send_notification_async(self.user, notification_data)
                
                mock_send_push.assert_called_once_with(
                    self.user, "Playfit", "sender_user has completed some workouts"
                )
        
        asyncio.run(run_async_test())