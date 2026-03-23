from django.views.generic import ListView, CreateView
from django.urls import reverse_lazy
from .models import Student

class StudentListView(ListView):
    model = Student
    template_name = 'student/student_list.html'
    context_object_name = 'students'

class StudentCreateView(CreateView):
    model = Student
    fields = ['first_name', 'last_name', 'email', 'grade']
    template_name = 'student/student_form.html'
    success_url = reverse_lazy('student_list')
