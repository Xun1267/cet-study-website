# 使用nginx作为基础镜像来托管静态网站
FROM nginx:alpine

# 设置工作目录
WORKDIR /usr/share/nginx/html

# 删除nginx默认的静态文件
RUN rm -rf /usr/share/nginx/html/*

# 复制项目文件到nginx目录
COPY index.html /usr/share/nginx/html/
COPY js/ /usr/share/nginx/html/js/
COPY docs/ /usr/share/nginx/html/docs/

# 创建nginx配置文件，支持SPA路由
RUN echo 'server {\n\
    listen 80;\n\
    server_name localhost;\n\
    root /usr/share/nginx/html;\n\
    index index.html;\n\
    \n\
    # 支持SPA路由\n\
    location / {\n\
        try_files $uri $uri/ /index.html;\n\
    }\n\
    \n\
    # 静态资源缓存\n\
    location ~* \\.(js|css|png|jpg|jpeg|gif|ico|svg)$ {\n\
        expires 1y;\n\
        add_header Cache-Control "public, immutable";\n\
    }\n\
    \n\
    # 安全头\n\
    add_header X-Frame-Options "SAMEORIGIN" always;\n\
    add_header X-Content-Type-Options "nosniff" always;\n\
    add_header X-XSS-Protection "1; mode=block" always;\n\
}' > /etc/nginx/conf.d/default.conf

# 暴露80端口
EXPOSE 80

# 启动nginx
CMD ["nginx", "-g", "daemon off;"]