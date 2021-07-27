FROM sonarsource/sonar-scanner-cli:4.6

RUN ln -s /usr/bin/sonar-scanner-run.sh /bin/gitlab-sonar-scanner

COPY sonar-scanner-run.sh /usr/bin
COPY quality-gate.sh /usr/bin
