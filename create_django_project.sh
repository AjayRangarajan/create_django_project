echo "Welcome to django project creator script!!!"

mkdir "django_project"
cd "django_project"

pip install pipenv
pipenv install django

read -p "Enter your project name: " PROJECT_NAME

django-admin startproject "$PROJECT_NAME"
cd "$PROJECT_NAME"
pipenv lock -r > requirements.txt

read -p "Enter the name of your home/index app: " APP_NAME
python3 manage.py startapp "$APP_NAME"
cd "$APP_NAME" #into the app
mkdir templates
cd templates
mkdir "$APP_NAME"
touch layout.html
cat << EOF > layout.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ title }}</title>
</head>
<body>
    {% block head %}
    {% endblock head %}

    {% block content %}
    {% endblock content %}

    {% block foot %}
    {% endblock foot %}
</body>
</html>
EOF

touch home.html
cat << EOF home.html
{% extends 'home/layout.html' %}

{% block head %}
<h1>Welcome to the home page!!!</h1>
{% endblock head %}

{% block content %}
{% endblock content %}

{% block foot %}
{% endblock foot %}
EOF

cd .. #into the templates directory
cd .. #into the app directory

mkdir static
cd static
mkdir "$APP_NAME"
touch main.css
cd .. #into the templates directory
cd .. #into the app directory

read -p "Enter the name of your home function: " FUNCTION_NAME
sed -i "s|# Create your views here.|def ${FUNCTION_NAME}(request):\ncontext = {\n    'title': 'home',\n    }\n    return render(request, '${APP_NAME}/home.html', context) |" views.py

touch urls.py
cat << EOF > urls.py
from django.urls import path
from . import views

app_name = '${APP_NAME}'

urlpatterns = [
    path('', views.${FUNCTION_NAME}, name='${FUNCTION_NAME}'),
]
EOF

cd .. #into the project directory
cd "$PROJECT_NAME" #into the project directory that contains settings.py file

sed -i "/django.contrib.staticfiles/a\ \t'$APP_NAME.apps.${APP_NAME}Config'," settings.py

sed -i "/from django.urls import path/s/, include/" urls.py
sed -i "/admin.site.urls/a\ \tpath('', include('${APP_NAME}.urls'))," urls.py


python3 manage.py makemigrations
python3 manage.py migrate

echo "Creating the superuser for the web application.\nplease enter the required inputs when asked."
python3 manage.py createsuperuser

