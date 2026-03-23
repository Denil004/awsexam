from django.urls import path
from .views import StudentListView, StudentCreateView

urlpatterns = [
    path('', StudentListView.as_view(), name='student_list'),
    path('add/', StudentCreateView.as_view(), name='student_add'),
]
