
docker_stop(cntnr_id = 'blast_1')
docker_start(cntnr_id = 'blast_1', img_id = 'blast')

docker_exec('blast_1', 'blastn', '-h')
