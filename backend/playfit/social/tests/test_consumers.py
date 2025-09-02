import asyncio
import json
from unittest.mock import patch, AsyncMock, MagicMock
from django.test import TestCase
from django.contrib.auth.models import AnonymousUser
from authentification.models import CustomUser
from social.consumers import NotificationConsumer
from social.models import Notification, Follow


class NotificationConsumerTestCase(TestCase):
    
    def setUp(self):
        self.user = CustomUser.objects.create(
            username='testuser',
            email='test@example.com',
            password='testpass',
            date_of_birth='1990-01-01',
            height=180,
            weight=80,
            email_hash='testhash1'
        )
        self.user2 = CustomUser.objects.create(
            username='testuser2', 
            email='test2@example.com',
            password='testpass2',
            date_of_birth='1990-01-01',
            height=180,
            weight=80,
            email_hash='testhash2'
        )

    def test_consumer_inheritance_and_methods(self):
        """Test that consumer inherits properly and has required methods"""
        consumer = NotificationConsumer()
        self.assertTrue(hasattr(consumer, 'connect'))
        self.assertTrue(hasattr(consumer, 'disconnect'))
        self.assertTrue(hasattr(consumer, 'receive'))
        self.assertTrue(hasattr(consumer, 'send_notification'))
        self.assertTrue(hasattr(consumer, 'mark_notifications_as_seen'))
        self.assertTrue(hasattr(consumer, 'get_followers'))
        self.assertTrue(hasattr(consumer, 'create_worldposition_notifications'))

    def test_connect_with_unauthenticated_user(self):
        """Test WebSocket connection with unauthenticated user"""
        async def run_test():
            user = AnonymousUser()
            
            consumer = NotificationConsumer()
            consumer.scope = {'user': user}
            consumer.close = AsyncMock()
            
            await consumer.connect()
            
            consumer.close.assert_called_once()

        asyncio.run(run_test())

    def test_disconnect_with_unauthenticated_user(self):
        """Test WebSocket disconnection with unauthenticated user"""
        async def run_test():
            user = AnonymousUser()
            
            consumer = NotificationConsumer()
            consumer.scope = {'user': user}
            consumer.user = user
            
            # Should not call any cleanup methods for unauthenticated users
            with patch.object(consumer, 'get_followers') as mock_get_followers:
                with patch('utilities.redis.redis_client') as mock_redis:
                    await consumer.disconnect(1000)
                    
                    # These should not be called for unauthenticated users
                    mock_get_followers.assert_not_called()
                    mock_redis.delete.assert_not_called()

        asyncio.run(run_test())

    def test_receive_mark_as_seen(self):
        """Test receiving mark_as_seen action"""
        async def run_test():
            consumer = NotificationConsumer()
            consumer.scope = {'user': self.user}
            consumer.user = self.user
            
            with patch.object(consumer, 'mark_notifications_as_seen', new_callable=AsyncMock) as mock_mark_seen:
                test_data = '{"action": "mark_as_seen"}'
                
                await consumer.receive(text_data=test_data)
                
                mock_mark_seen.assert_called_once()

        asyncio.run(run_test())

    def test_receive_other_action(self):
        """Test receiving message with different action"""
        async def run_test():
            consumer = NotificationConsumer()
            consumer.scope = {'user': self.user}
            consumer.user = self.user
            
            with patch.object(consumer, 'mark_notifications_as_seen', new_callable=AsyncMock) as mock_mark_seen:
                test_data = '{"action": "other_action"}'
                
                await consumer.receive(text_data=test_data)
                
                # Should not be called for other actions
                mock_mark_seen.assert_not_called()

        asyncio.run(run_test())

    def test_receive_with_no_action(self):
        """Test receiving message without action field"""
        async def run_test():
            consumer = NotificationConsumer()
            consumer.scope = {'user': self.user}
            consumer.user = self.user
            
            with patch.object(consumer, 'mark_notifications_as_seen', new_callable=AsyncMock) as mock_mark_seen:
                test_data = '{"message": "hello"}'
                
                await consumer.receive(text_data=test_data)
                
                # Should not be called when no action specified
                mock_mark_seen.assert_not_called()

        asyncio.run(run_test())

    def test_receive_with_invalid_json(self):
        """Test receiving invalid JSON message raises error"""
        async def run_test():
            consumer = NotificationConsumer()
            consumer.scope = {'user': self.user}
            consumer.user = self.user
            
            # This should raise a JSONDecodeError
            with self.assertRaises(json.JSONDecodeError):
                await consumer.receive(text_data="invalid json")

        asyncio.run(run_test())

    def test_send_notification(self):
        """Test sending notification through WebSocket"""
        async def run_test():
            consumer = NotificationConsumer()
            consumer.send = AsyncMock()
            
            event = {
                'message': {
                    'id': 1,
                    'sender': 'testuser',
                    'notification_type': 'like'
                }
            }
            
            await consumer.send_notification(event)
            
            # Verify send was called with proper JSON
            consumer.send.assert_called_once_with(
                text_data=json.dumps(event["message"])
            )

        asyncio.run(run_test())

    def test_mark_notifications_as_seen_sync(self):
        """Test marking notifications as seen synchronously"""
        notification = Notification.objects.create(
            user=self.user,
            sender=self.user2,
            notification_type='like',
            seen=False
        )
        
        consumer = NotificationConsumer()
        consumer.user = self.user
        
        # Test the sync version by accessing the original function
        from social import consumers as consumer_module
        sync_method = consumer_module.NotificationConsumer.__dict__['mark_notifications_as_seen'].func
        sync_method(consumer)
        
        notification.refresh_from_db()
        self.assertTrue(notification.seen)

    def test_get_followers_authenticated_sync(self):
        """Test getting user followers when authenticated synchronously"""
        # Add a follower relationship
        Follow.objects.create(follower=self.user2, following=self.user)
        
        consumer = NotificationConsumer()
        consumer.user = self.user
        
        # Test the sync version
        from social import consumers as consumer_module
        sync_method = consumer_module.NotificationConsumer.__dict__['get_followers'].func
        followers = sync_method(consumer)
        
        self.assertEqual(len(followers), 1)
        self.assertEqual(followers[0], self.user2)

    def test_get_followers_unauthenticated_sync(self):
        """Test getting followers when user is not authenticated synchronously"""
        user = AnonymousUser()
        
        consumer = NotificationConsumer()
        consumer.user = user
        
        # Test the sync version
        from social import consumers as consumer_module
        sync_method = consumer_module.NotificationConsumer.__dict__['get_followers'].func
        followers = sync_method(consumer)
        
        self.assertEqual(followers, [])

    def test_create_worldposition_notifications_sync(self):
        """Test creating world position notifications synchronously"""
        consumer = NotificationConsumer()
        
        followers = [self.user2]
        notification_data = {
            "sender": self.user,
            "notification_type": "world_position",
            "post": None,
        }
        
        # Test the sync version
        from social import consumers as consumer_module
        sync_method = consumer_module.NotificationConsumer.__dict__['create_worldposition_notifications'].func
        notifications = sync_method(consumer, followers, notification_data)
        
        self.assertEqual(len(notifications), 1)
        self.assertEqual(notifications[0].user, self.user2)
        self.assertEqual(notifications[0].sender, self.user)
        self.assertEqual(notifications[0].notification_type, "world_position")
        self.assertIsNone(notifications[0].post)

    def test_create_worldposition_notifications_multiple_followers(self):
        """Test creating notifications for multiple followers"""
        user3 = CustomUser.objects.create(
            username='testuser3',
            email='test3@example.com',
            password='testpass3',
            date_of_birth='1990-01-01',
            height=180,
            weight=80,
            email_hash='testhash3'
        )
        
        consumer = NotificationConsumer()
        
        followers = [self.user2, user3]
        notification_data = {
            "sender": self.user,
            "notification_type": "world_position",
            "post": None,
        }
        
        # Test the sync version
        from social import consumers as consumer_module
        sync_method = consumer_module.NotificationConsumer.__dict__['create_worldposition_notifications'].func
        notifications = sync_method(consumer, followers, notification_data)
        
        self.assertEqual(len(notifications), 2)
        notification_users = [notif.user for notif in notifications]
        self.assertIn(self.user2, notification_users)
        self.assertIn(user3, notification_users)

    def test_connect_with_redis_error(self):
        """Test connection handling when Redis is unavailable"""
        async def run_test():
            with patch('utilities.redis.redis_client') as mock_redis_client:
                mock_redis_client.set.side_effect = Exception("Redis connection failed")
                
                consumer = NotificationConsumer()
                consumer.scope = {'user': self.user}
                consumer.channel_name = 'test_channel'
                consumer.channel_layer = MagicMock()
                consumer.channel_layer.group_add = AsyncMock()
                consumer.accept = AsyncMock()
                
                # The connect method should raise an exception when Redis fails
                with self.assertRaises(Exception):
                    await consumer.connect()

        asyncio.run(run_test())

    def test_disconnect_with_redis_error(self):
        """Test disconnect handling when Redis is unavailable"""
        async def run_test():
            consumer = NotificationConsumer()
            consumer.scope = {'user': self.user}
            consumer.channel_name = 'test_channel'
            consumer.user = self.user
            consumer.room_group_name = f"notifications_{self.user.id}"
            
            # Mock the channel layer
            consumer.channel_layer = MagicMock()
            consumer.channel_layer.group_discard = AsyncMock()
            
            with patch.object(consumer, 'get_followers', return_value=[]):
                with patch.object(consumer, 'create_worldposition_notifications', return_value=[]):
                    with patch('utilities.redis.redis_client') as mock_redis:
                        mock_redis.delete.side_effect = Exception("Redis connection failed")
                        
                        # Should raise exception when Redis fails
                        with self.assertRaises(Exception):
                            await consumer.disconnect(1000)

        asyncio.run(run_test())
