from django.urls import path
from .views import ReportCreateView, ReportedUsersListView, ban_user, delete_user

urlpatterns = [
    path('report/', ReportCreateView.as_view(), name='report-user'),
    path('reports/', ReportedUsersListView.as_view(), name='reported-users-list'),
    path('ban/<int:user_id>/', ban_user, name='ban-user'),
    path('delete/<int:user_id>/', delete_user, name='delete-user'),
]
