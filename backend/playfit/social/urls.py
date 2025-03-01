from django.urls import path
from .views import (
    FollowersListView,
    FollowingListView,
    FollowCreateView,
    FollowDeleteView,
    PostCreateView,
    PostListView,
    LikePostView,
    UnlikePostView,
    CommentCreateView,
    CommentDeleteView,
    NotificationListView,
    NotificationReadView,
    NotificationReadAllView,
)

urlpatterns = [
    path('followers/', FollowersListView.as_view(), name='followers'),
    path('following/', FollowingListView.as_view(), name='following'),
    path('follow/', FollowCreateView.as_view(), name='follow'),
    path('unfollow/<int:id>/', FollowDeleteView.as_view(), name='unfollow'),
    path('posts/', PostListView.as_view(), name='posts'),
    path('posts/<int:id>/like/', LikePostView.as_view(), name='like'),
    path('posts/<int:id>/unlike/', UnlikePostView.as_view(), name='unlike'),
    path('posts/create/', PostCreateView.as_view(), name='create_post'),
    path('posts/<int:id>/comment/', CommentCreateView.as_view(), name='comment'),
    path('comments/<int:id>/delete/', CommentDeleteView.as_view(), name='delete_comment'),
    path('notifications/', NotificationListView.as_view(), name='notifications'),
    path('notifications/read/<int:id>/', NotificationReadView.as_view(), name='read_notification'),
    path('notifications/read/all/', NotificationReadAllView.as_view(), name='read_all_notifications'),
]
