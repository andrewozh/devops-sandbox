import type {ReactNode} from 'react';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';
import styles from './cv.module.css';

export default function CV(): ReactNode {
  return (
    <Layout
      title="CV - Andrew Ozhegov"
      description="Andrew Ozhegov's Curriculum Vitae">
      <div className={styles.cvPage}>
        <div className={styles.cvContainer}>
          <div className={styles.cvHeader}>
            <div className={styles.actionButtons}>
              <a
                href="/cv.pdf"
                className={styles.downloadButton}
                download="Andrew_Ozhegov_CV.pdf"
              >
                Download PDF
              </a>
              <a
                href="https://www.linkedin.com/in/andrewozh"
                target="_blank"
                rel="noopener noreferrer"
                className={styles.linkedinButton}
              >
                <svg className={styles.linkedinIcon} viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                  <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/>
                </svg>
                LinkedIn
              </a>
            </div>
          </div>

          <div className={styles.cvContent}>
            <h1 className={styles.cvTitle}>Andrew Ozhegov</h1>
            
            <div className={styles.cvSubtitle}>
              DevOps Engineer at Intento, Inc.
            </div>

            <div className={styles.cvLocation}>
              Istanbul, Türkiye
            </div>

            <section className={styles.cvSection}>
              <Heading as="h2">Contact Information</Heading>
              <p>
                <strong>Email:</strong> <a href="mailto:andrew.ozhegov@gmail.com">andrew.ozhegov@gmail.com</a><br/>
                <strong>LinkedIn:</strong> <a href="https://www.linkedin.com/in/andrewozh" target="_blank">linkedin.com/in/andrewozh</a><br/>
                <strong>GitHub:</strong> <a href="https://github.com/andrewozh" target="_blank">github.com/andrewozh</a>
              </p>
            </section>

            <section className={styles.cvSection}>
              <Heading as="h2">Summary</Heading>
              <p>
                I have 4+ years of Software and DevOps Engineering experience. In the beginning of my career, 
                I took part in building Continuous Integration (CI) pipelines, creating build and runtime 
                infrastructure for Linux software. Also worked on internal-needs Kubernetes cluster. Then I 
                was busy developing software working with proprietary embedded platforms related to video 
                processing with neural networks using C++. As a DevOps Engineer I'm working on AWS infrastructure 
                using IaC tools (Terraform). I have done migration of local databases to SaaS, set up application 
                Monitoring and Log management. Also automate configuration using Ansible and develop an application 
                scaling mechanism.
              </p>
            </section>

            <section className={styles.cvSection}>
              <Heading as="h2">Experience</Heading>
              
              <div className={styles.experienceItem}>
                <h3 className={styles.jobTitle}>DevOps Engineer</h3>
                <p className={styles.companyInfo}>
                  Intento, Inc. • December 2022 - Present (2 years 9 months)
                </p>
              </div>

              <div className={styles.experienceItem}>
                <h3 className={styles.jobTitle}>DevOps Engineer</h3>
                <p className={styles.companyInfo}>
                  DRCT • November 2021 - September 2022 (11 months)
                </p>
                <ul>
                  <li>Built a network infrastructure (VPC, VPN) on AWS using Terraform</li>
                  <li>Migrated local databases (Redis, MongoDB, PostgreSQL) to SaaS (ElastiCache, Atlas, RDS)</li>
                  <li>Set up application monitoring with Datadog and log management with Elastic Stack</li>
                  <li>Implemented managing Configuration as Code using Ansible</li>
                  <li>Developed application scaling mechanisms on AWS using Terraform</li>
                </ul>
              </div>

              <div className={styles.experienceItem}>
                <h3 className={styles.jobTitle}>Software Engineer</h3>
                <p className={styles.companyInfo}>
                  AxxonSoft • July 2018 - November 2020 (2 years 5 months)
                </p>
                <ul>
                  <li>Created Build and Continuous Integration pipelines</li>
                  <li>Developed Docker images with complex applications for CI and external needs</li>
                  <li>Software development on C++ for Linux and embedded Linux-based platforms</li>
                  <li>Unix Shell/Bash scripting</li>
                </ul>
              </div>
            </section>

            <section className={styles.cvSection}>
              <Heading as="h2">Education</Heading>
              <div className={styles.experienceItem}>
                <h3 className={styles.jobTitle}>Bachelor's degree, Information Technology</h3>
                <p className={styles.companyInfo}>
                  Sevastopol State Technical University • 2014 - 2018
                </p>
              </div>
            </section>

            <section className={styles.cvSection}>
              <Heading as="h2">Top Skills</Heading>
              <ul>
                <li><strong>Amazon Web Services (AWS)</strong></li>
                <li><strong>Kubernetes</strong></li>
                <li><strong>Continuous Integration and Continuous Delivery (CI/CD)</strong></li>
                <li><strong>Terraform</strong></li>
                <li><strong>Docker</strong></li>
                <li><strong>Ansible</strong></li>
                <li><strong>Linux</strong></li>
                <li><strong>C++</strong></li>
              </ul>
            </section>

            <section className={styles.cvSection}>
              <Heading as="h2">Languages</Heading>
              <ul>
                <li><strong>Ukrainian:</strong> Native or Bilingual</li>
                <li><strong>English:</strong> Professional Working</li>
                <li><strong>Russian:</strong> Native or Bilingual</li>
              </ul>
            </section>
          </div>
        </div>
      </div>
    </Layout>
  );
}
