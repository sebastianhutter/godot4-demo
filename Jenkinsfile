//
// test and build pipeline for sample godot project
//


// export template which exports no scenes or resources
// an initial export in a fresh git checkout is required 
// so the project is initialized, the .godot folder is created
// and gdunit4 can run 
export_template_gdunit4='''
[preset.0]

name="gdunit4"
platform="Linux/X11"
runnable=false
dedicated_server=false
custom_features=""
export_filter="resources"
export_files=PackedStringArray()
include_filter=""
exclude_filter=""
export_path=""
encryption_include_filters=""
encryption_exclude_filters=""
encrypt_pck=false
encrypt_directory=false
script_encryption_key=""

[preset.0.options]

custom_template/debug=""
custom_template/release=""
debug/export_console_script=1
binary_format/embed_pck=false
texture_format/bptc=true
texture_format/s3tc=true
texture_format/etc=false
texture_format/etc2=false
binary_format/architecture="x86_64"
ssh_remote_deploy/enabled=false
ssh_remote_deploy/host="user@host_ip"
ssh_remote_deploy/port="22"
ssh_remote_deploy/extra_args_ssh=""
ssh_remote_deploy/extra_args_scp=""
ssh_remote_deploy/run_script="#!/usr/bin/env bash
export DISPLAY=:0
unzip -o -q \"{temp_dir}/{archive_name}\" -d \"{temp_dir}\"
\"{temp_dir}/{exe_name}\" {cmd_args}"
ssh_remote_deploy/cleanup_script="#!/usr/bin/env bash
kill $(pgrep -x -f \"{temp_dir}/{exe_name} {cmd_args}\")
rm -rf \"{temp_dir}\""
'''


pipeline {
    options { 
      disableConcurrentBuilds() 
    }
    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 1000
  containers:
  - name: build-container
    image: sebastianhutter/godot-runner:main
    imagePullPolicy: Always
    command:
    - cat
    tty: true
    volumeMounts:
    - mountPath: /dev/snd
      name: dev-snd
    securityContext:
      # required for /dev/snd device access
      privileged: true
    resources:
      limits:
        # https://kubernetes.io/docs/tasks/manage-gpus/scheduling-gpus/
        # reserve nvidia graphics card in host
        nvidia.com/gpu: 1
  volumes:
  - name: dev-snd
    hostPath:
      path: /dev/snd
"""
        }
    }
    stages {
        stage('Prepare container') {
            steps {
                container('build-container') {
                    sh( 
                        script: """
                            sudo Xvfb -ac \${DISPLAY} -screen 0 1280x1024x24 > /dev/null &
                        """
                    )
                }
            }
        }
        stage('Test') {
            steps {
                container('build-container') {
                    sh(
                        script: 'mv export_presets.cfg export_presets.cfg.original'
                    )
                    writeFile(
                        file: 'export_presets.cfg',
                        text: export_template_gdunit4,
                        encoding: 'UTF-8'
                    )
                    sh(
                        script: '''
                            $GODOT_BIN --export-release "gdunit4" /tmp/gdunit4
                            rm -f /tmp/gdunit4
                            mv export_presets.cfg.original export_presets.cfg
                        '''
                    )
                    sh(
                        script: 'bash addons/gdUnit4/runtest.sh -a ./test'
                    )
                }
            }
            post {
                always {
                    container('build-container') {
                        junit(
                            testResults: '**/reports/report_1/**/results.xml',
                            allowEmptyResults: true,
                        )
                    }
                }
            }
        }
        stage('Build on Platforms') {
            when {
                anyOf {
                    tag "*"
                    branch "main"
                }
            }
            matrix {
                axes {
                    axis {
                        name "PLATFORM"
                        values "linux", "windows" 
                    }
                }
                stages {
                    stage('Build') {
                        steps {
                            container('build-container') {
                                script {
                                    def fileName = null
                                    switch(env.PLATFORM) {
                                        case "linux":
                                            fileName = "godot4-demo.bin";
                                            break;
                                        case "windows":
                                            fileName = "godot4-demo.exe";
                                            break;
                                        default:
                                            throw new Exception ("Unknown platform")
                                    }
                                }
                                sh(
                                    script: """
                                        mkdir -p build/\${PLATFORM}
                                        \$GODOT_BIN --export-release "\${PLATFORM}" build/\${PLATFORM}\${fileName}
                                    """
                                )
                            }
                        }
                    }
                }
            }
            post {
                success {
                    archiveArtifacts(
                        artifacts: "build/**/*",
                        fingerprint: true
                    )
                }
            }
        }
    }
}
