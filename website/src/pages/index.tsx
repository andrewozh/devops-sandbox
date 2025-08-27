import type {ReactNode} from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import HomepageFeatures from '@site/src/components/HomepageFeatures';
import Heading from '@theme/Heading';
import React, { useState, useEffect } from 'react';

import styles from './index.module.css';

function HomepageHeader() {
  const [currentRole, setCurrentRole] = useState(0);
  const [displayText, setDisplayText] = useState('DevOps');
  const [isDecoding, setIsDecoding] = useState(false);
  const roles = ['DevOps', 'Cloud', 'Platform'];

  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*';
  
  const decodeText = (targetText: string, callback?: () => void) => {
    setIsDecoding(true);
    const targetLength = targetText.length;
    let iterations = 0;
    const maxIterations = targetLength * 3; // Reduced iterations for faster decoding
    
    const interval = setInterval(() => {
      let decoded = '';
      
      for (let i = 0; i < targetLength; i++) {
        if (iterations >= i * 3) {
          // Character is fully decoded
          decoded += targetText[i];
        } else {
          // Character is still decoding
          decoded += characters[Math.floor(Math.random() * characters.length)];
        }
      }
      
      setDisplayText(decoded);
      iterations++;
      
      if (iterations >= maxIterations) {
        clearInterval(interval);
        setDisplayText(targetText);
        setIsDecoding(false);
        callback && callback();
      }
    }, 40); // Faster decoding speed - 25ms intervals
  };

  useEffect(() => {
    const roleInterval = setInterval(() => {
      const nextRole = (currentRole + 1) % roles.length;
      decodeText(roles[nextRole], () => {
        setCurrentRole(nextRole);
      });
    }, 3000); // Change every 3 seconds (longer to accommodate decoding)

    return () => clearInterval(roleInterval);
  }, [currentRole, roles]);

  return (
    <header className={clsx('hero hero--primary', styles.heroBanner)}>
      <div className={styles.heroContent}>
        <div className={styles.heroText}>
          <h1 className={styles.heroTitle}>
            Hi, I'm Andrew Ozhegov
          </h1>
          <div className={styles.roleContainer}>
            <div className={styles.roleCarousel}>
              <span className={`${styles.roleText} ${isDecoding ? 'decoding' : ''}`}>
                {displayText}
              </span>
            </div>
            <span className={styles.engineerText}>Engineer</span>
          </div>
        </div>
        <div className={styles.heroDescription}>
          <p className={styles.descriptionText}>
            My goal here, is to combine the most useful devops practices and tools into a single sophisticated project,
            that can be used not only as a <span className={styles.accentWord}>demo</span> of my skills and <span className={styles.accentWord}>sandbox</span> for learning new tools and practices but also a
            the infra <span className={styles.accentWord}>foundation</span> for the company of any size.
          </p>
        </div>
        <div className={styles.heroButtons}>
          <Link
            className={clsx('button button--primary button--lg', styles.cvButton)}
            to="/cv">
            Check out my CV
          </Link>
          <Link
            className={clsx('button button--primary button--lg', styles.sandboxButton)}
            to="/docs/">
            Demo project
          </Link>
          <Link
            className={clsx('button button--secondary button--lg', styles.emailButton)}
            href="mailto:andrewozhegov@gmail.com">
            Email Me
          </Link>
        </div>
      </div>
    </header>
  );
}

export default function Home(): ReactNode {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={`Hello from ${siteConfig.title}`}
      description="Description will go into a meta tag in <head />">
      <HomepageHeader />
      <main>
        <HomepageFeatures />
      </main>
    </Layout>
  );
}
