import type {ReactNode} from 'react';
import Layout from '@theme/Layout';
import styles from './cv.module.css';

export default function CV(): ReactNode {
  return (
    <Layout
      title="CV - Andrew Ozhegov"
      description="Andrew Ozhegov's Curriculum Vitae">
      <div className={styles.cvPage}>
        <div className={styles.cvContainer}>

          <div className={styles.intro}>
            <p className={styles.handwritten}>
              Here's my CV — download it, connect on LinkedIn, or just reach out via email.<br/>Always happy to chat ✌️
            </p>
            <div className={styles.actionButtons}>
              <a
                href="/cv-2026.pdf"
                className={styles.downloadButton}
                download="Andrew_Ozhegov_CV.pdf"
              >
                <svg className={styles.buttonIcon} viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                  <path d="M12 16l-6-6h4V4h4v6h4l-6 6zm-6 2h12v2H6v-2z"/>
                </svg>
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
              <a
                href="mailto:andrew.ozhegov@gmail.com"
                className={styles.emailButton}
              >
                <svg className={styles.buttonIcon} viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                  <path d="M20 4H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/>
                </svg>
                Email me
              </a>
            </div>
          </div>

          <div className={styles.macWindow}>
            <div className={styles.macTitleBar}>
              <span className={`${styles.macDot} ${styles.macDotClose}`} />
              <span className={`${styles.macDot} ${styles.macDotMinimize}`} />
              <span className={`${styles.macDot} ${styles.macDotMaximize}`} />
              <span className={styles.macTitle}>cv-2026.pdf</span>
            </div>
            <iframe
              src="/cv-2026.pdf"
              className={styles.cvEmbed}
              title="Andrew Ozhegov CV"
            />
          </div>

        </div>
      </div>
    </Layout>
  );
}
