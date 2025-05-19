from django.urls import path
from .views import ReportCreateView, ReportedUsersListView, ban_user, delete_user

urlpatterns = [
    path('report/', ReportCreateView.as_view(), name='report-user'),
    path('reports/', ReportedUsersListView.as_view(), name='reported-users-list'),
    path('ban/<str:username>/', ban_user, name='ban-user'),
    path('delete/<str:username>/', delete_user, name='delete-user'),
]
