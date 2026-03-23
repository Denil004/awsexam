from django.views.generic import ListView, CreateView, UpdateView, DeleteView, DetailView
from django.urls import reverse_lazy
from .models import Student

class StudentListView(ListView):
    model = Student
    template_name = 'student/student_list.html'
    context_object_name = 'students'

class StudentDetailView(DetailView):
    model = Student
    template_name = 'student/student_detail.html'
    context_object_name = 'student'

class StudentCreateView(CreateView):
    model = Student
    fields = ['first_name', 'last_name', 'email', 'grade']
    template_name = 'student/student_form.html'
    success_url = reverse_lazy('student_list')

class StudentUpdateView(UpdateView):
    model = Student
    fields = ['first_name', 'last_name', 'email', 'grade']
    template_name = 'student/student_form.html'
    success_url = reverse_lazy('student_list')

class StudentDeleteView(DeleteView):
    model = Student
    template_name = 'student/student_confirm_delete.html'
    success_url = reverse_lazy('student_list')
