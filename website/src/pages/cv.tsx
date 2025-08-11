import type {ReactNode} from 'react';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';

export default function CV(): ReactNode {
  return (
    <Layout
      title="CV - Andrew Ozhegov"
      description="Andrew Ozhegov's Curriculum Vitae">
      <div style={{
        maxWidth: '800px',
        margin: '2rem auto',
        padding: '0 2rem',
        lineHeight: '1.6'
      }}>
        <Heading as="h1" style={{
          textAlign: 'center',
          marginBottom: '1rem',
          color: 'var(--ifm-color-primary)'
        }}>
          Andrew Ozhegov
        </Heading>
        
        <div style={{
          textAlign: 'center',
          marginBottom: '1rem',
          fontSize: '1.2rem',
          color: 'var(--ifm-color-primary-dark)',
          fontWeight: '600'
        }}>
          DevOps Engineer at Intento, Inc.
        </div>

        <div style={{
          textAlign: 'center',
          marginBottom: '3rem',
          fontSize: '1rem',
          color: 'var(--ifm-color-emphasis-700)'
        }}>
          Istanbul, Türkiye
        </div>

        <section style={{ marginBottom: '2rem' }}>
          <Heading as="h2">Contact Information</Heading>
          <p>
            <strong>Email:</strong> <a href="mailto:andrew.ozhegov@gmail.com">andrew.ozhegov@gmail.com</a><br/>
            <strong>LinkedIn:</strong> <a href="https://www.linkedin.com/in/andrewozh" target="_blank">linkedin.com/in/andrewozh</a><br/>
            <strong>GitHub:</strong> <a href="https://github.com/andrewozh" target="_blank">github.com/andrewozh</a>
          </p>
        </section>

        <section style={{ marginBottom: '2rem' }}>
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

        <section style={{ marginBottom: '2rem' }}>
          <Heading as="h2">Experience</Heading>
          
          <div style={{ marginBottom: '2rem' }}>
            <h3 style={{ marginBottom: '0.5rem', color: 'var(--ifm-color-primary-dark)' }}>DevOps Engineer</h3>
            <p style={{ fontStyle: 'italic', marginBottom: '0.5rem', fontWeight: '600' }}>
              Intento, Inc. • December 2022 - Present (2 years 9 months)
            </p>
          </div>

          <div style={{ marginBottom: '2rem' }}>
            <h3 style={{ marginBottom: '0.5rem', color: 'var(--ifm-color-primary-dark)' }}>DevOps Engineer</h3>
            <p style={{ fontStyle: 'italic', marginBottom: '0.5rem', fontWeight: '600' }}>
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

          <div style={{ marginBottom: '2rem' }}>
            <h3 style={{ marginBottom: '0.5rem', color: 'var(--ifm-color-primary-dark)' }}>Software Engineer</h3>
            <p style={{ fontStyle: 'italic', marginBottom: '0.5rem', fontWeight: '600' }}>
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

        <section style={{ marginBottom: '2rem' }}>
          <Heading as="h2">Education</Heading>
          <div>
            <h3 style={{ marginBottom: '0.5rem', color: 'var(--ifm-color-primary-dark)' }}>Bachelor's degree, Information Technology</h3>
            <p style={{ fontStyle: 'italic', marginBottom: '0.5rem' }}>
              Sevastopol State Technical University • 2014 - 2018
            </p>
          </div>
        </section>

        <section style={{ marginBottom: '2rem' }}>
          <Heading as="h2">Top Skills</Heading>
          <ul>
            <li><strong>Amazon Web Services (AWS)</strong></li>
            <li><strong>Kubernetes</strong></li>
            <li><strong>Continuous Integration and Continuous Delivery (CI/CD)</strong></li>
          </ul>
        </section>

        <section style={{ marginBottom: '2rem' }}>
          <Heading as="h2">Languages</Heading>
          <ul>
            <li><strong>Ukrainian:</strong> Native or Bilingual</li>
            <li><strong>English:</strong> Professional Working</li>
            <li><strong>Russian:</strong> Native or Bilingual</li>
          </ul>
        </section>
      </div>
    </Layout>
  );
}
